#include "common.h"

#include "libdactl.h"

/* XXX this should all be changed later to asynchronous method */

#define MAX_SAMPLES 128
#define NSAMPLES    10
#define NDEV        1
#define NCHAN       16

void
threads_acq_func (GObject *data)
{
g_debug ("2");
    ApplicationData *app_data = (ApplicationData *)data;
    CldBuilder *builder = application_data_get_builder (app_data);
    gint delay;
    gdouble meas;
    GeeIterator *it;
    GeeCollection *values;
    gpointer value;
    gboolean has_next = false;

    /* comedi data */
    #ifdef USE_COMEDI
    gchar *devstr;
    gint ret, i, j, n, num;
    guint subdev[NDEV];
    //comedi_t *dev[NDEV];
    comedi_range *cr;
    comedi_insn insns[NDEV][NCHAN];
    comedi_insnlist insn_lists[NDEV];
    lsampl_t cdata[NDEV][NDEV*NCHAN][MAX_SAMPLES];
    lsampl_t maxdata;
    #else
    /*GTimeVal sample_time;*/
    #endif

    /* thread data */
    static GStaticMutex mutex = G_STATIC_MUTEX_INIT;
    GCond *cond = g_cond_new ();
    GTimeVal next_time;
    GMutex *meas_mutex = g_mutex_new ();

    /* setup comedi */
    #ifdef USE_COMEDI
    comedi_set_global_oor_behavior (COMEDI_OOR_NUMBER);

    for (i = 0; i < NDEV; i++)
    {
        /* open comedi devices */
        devstr = g_strdup_printf ("/dev/comedi%d", i+1);
        dev[i] = comedi_open (devstr);
        if (!dev[i])
        {
            application_data_stop_acquisition (APPLICATION_DATA (app_data));
            g_warning ("Failed to open comedi device: %s", dev);
        }
        g_debug ("Opened device: %s", devstr);
        g_free (devstr);

        insn_lists[i].n_insns = NCHAN;
        insn_lists[i].insns = insns[i];
        memset (&insns[i], 0, sizeof (comedi_insn));

        subdev[i] = comedi_find_subdevice_by_type (dev[i], COMEDI_SUBD_AI, 0);

        for (j = 0; j < NCHAN; j++)
        {
            insns[i][j].insn = INSN_READ;
            insns[i][j].n = NSAMPLES;
            insns[i][j].data = cdata[i][j + (i * NCHAN)];
            insns[i][j].subdev = subdev[i];
            insns[i][j].chanspec = CR_PACK (j, 0, AREF_DIFF);
        }
    }
    #endif

    delay = 1e6 / 100;       /* static 100 Hz for now */
    g_get_current_time (&next_time);

    while (application_data_get_acq_active (APPLICATION_DATA (app_data)))
    {
        g_mutex_lock (meas_mutex);

        /* execute instructions */
        #ifdef USE_COMEDI
        for (i = 0; i < NDEV; i++)
        {
            if ((ret = comedi_do_insnlist (dev[i], &insn_lists[i])) < 0)
                comedi_perror ("comedi_do_insnlist");
        }
        #endif

        /* process acquired data */
        values = gee_abstract_map_get_values ((GeeAbstractMap *)
                        application_data_get_ai_channels (app_data)
                    );
        it = gee_iterable_iterator ((GeeIterable *)values);

        for (has_next = gee_iterator_first (it); has_next; has_next = gee_iterator_next (it))
        {
            value = gee_iterator_get (it);

            #ifdef USE_COMEDI
            /* read new measurement from comedi compatible hardware */
            num = cld_channel_get_num (CLD_CHANNEL (value));
            /*n = (num < NCHAN) ? 0 : 1;*/
            n = 0;
            cr = comedi_get_range (dev[n], 0, num % NCHAN, 5);
            maxdata = comedi_get_maxdata (dev[n], 0, num % NCHAN);

            /* compute the average of our samples
             * XXX for the silly MCC PCI card this needs to start at 1 because
             *     the first scan is always wrong. */
            meas = 0.0;
            for (i = 1; i < NSAMPLES; i++)
                meas += comedi_to_phys (cdata[n][(num % NCHAN) + (n * NCHAN)][i], cr, maxdata);
            meas /= NSAMPLES;
            //g_debug ("dev: %d, chan: %d: chanmod: %d, meas: %f", n, num, num % NCHAN, meas);

            if (isnan (meas))
            {
                g_debug ("Channel %s out of range [%g,%g]",
                         cld_object_get_id (CLD_OBJECT (value)),
                         cr->min, cr->max);
                meas = cld_ai_channel_get_raw_value (CLD_AI_CHANNEL (value));
            }
            #else
            /* fill with meaningless data for testing purposes */
            /*
             *g_get_current_time (&sample_time);
             *double degs = (((double)sample_time.tv_sec / 60.0) * 360.0);
             *double rads = degs * 180.0 / 3.14159265359;
             *meas = sin (rads);
             */
            meas = (meas >= 10.0) ? 0 : meas + 0.01;
            #endif

            cld_ai_channel_add_raw_value (CLD_AI_CHANNEL (value), meas);
        }


        g_mutex_unlock (meas_mutex);

        /* add another delay */
        g_time_val_add (&next_time, delay);

        g_static_mutex_lock (&mutex);
        while (g_cond_timed_wait (cond,
                                  g_static_mutex_get_mutex (&mutex),
                                  &next_time))
            ; /* do nothing */
        g_static_mutex_unlock (&mutex);
    }

    #ifdef USE_COMEDI
    for (i = 0; i < NDEV; i++)
    {
        devstr = g_strdup_printf ("/dev/comedi%d", i);
        if (!dev[i])
        {
            if (comedi_close (dev[i]) < 0)
                g_warning ("Failed to close the device %s properly", devstr);
        }
        g_debug ("Closed device: %s", devstr);
        g_free (devstr);
    }
    #endif

    g_cond_free (cond);
g_debug ("3");
}

void
threads_write_func (GObject *data)
{
    ApplicationData *app_data = (ApplicationData *)data;
    gint delay, i;
    GeeIterator *it;
    GeeCollection *values;
    gpointer value;
    gboolean has_next = false;

    /* thread data */
    static GStaticMutex mutex = G_STATIC_MUTEX_INIT;
    GCond *cond = g_cond_new ();
    GTimeVal next_time;
    GMutex *write_mutex = g_mutex_new ();

    values = gee_abstract_map_get_values ((GeeAbstractMap *)
                application_data_get_ao_channels (app_data));

    /* comedi data */
    /* output */
/*
    #ifdef USE_COMEDI
    comedi_t *dev;

    if (!(dev = comedi_open ("/dev/comedi2")))
    {
        application_data_set_write_active (APPLICATION_DATA (app_data), false);
        g_warning ("Failed to open comedi device: %s", "/dev/comedi2");
    }
    g_debug ("Opened device: %s", "/dev/comedi2");
    #endif
*/

    delay = 1e6 / 100;       /* static 100 Hz for now */
    g_get_current_time (&next_time);

    while (application_data_get_write_active (APPLICATION_DATA (app_data)))
    {
        g_mutex_lock (write_mutex);

        /* fill cdata with values to output */
        it = gee_iterable_iterator ((GeeIterable *)values);
        for (has_next = gee_iterator_first (it); has_next; has_next = gee_iterator_next (it))
        {
            value = gee_iterator_get (it);
            gdouble val = cld_scalable_channel_get_scaled_value (CLD_ACHANNEL (value));
            gint num = cld_channel_get_num (CLD_CHANNEL (value));
            // g_debug ("num = %d, val = %.2f", num, val);
            guint16 out;
            val = (val < 0.0) ? 0.0 : val;
            val = (val > 100.0) ? 100.0 : val;
            #ifdef USE_COMEDI
            out = (val / 100.0) * 4095;
            comedi_data_write (dev[0], 1, num, 1, 0, out);
            #endif
        }

        g_mutex_unlock (write_mutex);

        /* add another delay */
        g_time_val_add (&next_time, delay);

        g_static_mutex_lock (&mutex);
        while (g_cond_timed_wait (cond,
                                  g_static_mutex_get_mutex (&mutex),
                                  &next_time))
            ; /* do nothing */
        g_static_mutex_unlock (&mutex);
    }

/*
    #ifdef USE_COMEDI
    if (!dev)
    {
        if (comedi_close (dev) < 0)
            g_warning ("Failed to close comedi device: %s", "/dev/comedi2");
    }
    g_debug ("Closed device: %s", "/dev/comedi2");
    #endif
*/
}
