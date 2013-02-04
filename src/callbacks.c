#include "common.h"

#include "libdactl.h"
#include "callbacks.h"

gboolean
cb_mnu_item_help_about_activate (GtkWidget *widget, gpointer data)
{
    ApplicationData *app_data = APPLICATION_DATA (data);
    UserInterfaceData *ui_data = USER_INTERFACE_DATA (application_data_get_ui (app_data));
    GtkWidget *dialog;

    dialog = GTK_WIDGET (user_interface_data_get_about_dialog (ui_data));
    gtk_dialog_run (GTK_DIALOG (dialog));
    gtk_widget_destroy (dialog);

    return false;
}

gboolean
cb_mnu_item_edit_pref_activate (GtkWidget *widget, gpointer data)
{
    ApplicationData *app_data = APPLICATION_DATA (data);
    GtkWidget *dialog = application_settings_dialog_new_with_startup_tab_id (app_data, 0);

    gtk_dialog_run (GTK_DIALOG (dialog));
    gtk_widget_destroy (dialog);

    return false;
}

gboolean
cb_mnu_item_edit_chan_activate (GtkWidget *widget, gpointer data)
{
    ApplicationData *app_data = APPLICATION_DATA (data);
    GtkWidget *dialog = application_settings_dialog_new_with_startup_tab_id (app_data, 2);

    gtk_dialog_run (GTK_DIALOG (dialog));
    gtk_widget_destroy (dialog);

    return false;
}

gboolean
cb_mnu_item_file_quit_activate (GtkWidget *widget, gpointer data)
{
    ApplicationData *app_data = APPLICATION_DATA (data);
    UserInterfaceData *ui_data = USER_INTERFACE_DATA (application_data_get_ui (app_data));
    int response;
    GtkWidget *dialog;

    dialog = gtk_message_dialog_new (GTK_WINDOW (user_interface_data_get_main_window (ui_data)),
                                     GTK_DIALOG_DESTROY_WITH_PARENT,
                                     GTK_MESSAGE_QUESTION,
                                     GTK_BUTTONS_YES_NO,
                                     "Are you sure you want to quit?");

    gtk_widget_show_all (dialog);
    response = gtk_dialog_run (GTK_DIALOG (dialog));
    gtk_widget_destroy (dialog);

    switch (response)
    {
        case GTK_RESPONSE_NO:
            break;
        case GTK_RESPONSE_YES:
            gtk_main_quit ();
            break;
        default:
            break;
    }

    return false;
}

gboolean
cb_btn_quit_clicked (GtkWidget *widget, gpointer data)
{
    ApplicationData *app_data = APPLICATION_DATA (data);
    UserInterfaceData *ui_data = USER_INTERFACE_DATA (application_data_get_ui (app_data));
    int response;
    GtkWidget *dialog;

    dialog = gtk_message_dialog_new (GTK_WINDOW (user_interface_data_get_main_window (ui_data)),
                                     GTK_DIALOG_DESTROY_WITH_PARENT,
                                     GTK_MESSAGE_QUESTION,
                                     GTK_BUTTONS_YES_NO,
                                     "Are you sure you want to quit?");

    gtk_widget_show_all (dialog);
    response = gtk_dialog_run (GTK_DIALOG (dialog));
    gtk_widget_destroy (dialog);

    switch (response)
    {
        case GTK_RESPONSE_NO:
            break;
        case GTK_RESPONSE_YES:
            gtk_main_quit ();
            break;
        default:
            break;
    }

    return false;
}

gboolean
cb_btn_pref_clicked (GtkWidget *widget, gpointer data)
{
    ApplicationData *app_data = APPLICATION_DATA (data);
    GtkWidget *dialog = application_settings_dialog_new_with_startup_tab_id (app_data, 0);

    gtk_dialog_run (GTK_DIALOG (dialog));
    gtk_widget_destroy (dialog);

    return false;
}

static void
update_aichannel_config (CldXmlConfig *xml, GeeMap *channels)
{
    gchar *value, *xpath;
    gboolean has_next;
    CldObject *channel;
    GeeMapIterator *it = gee_map_map_iterator (channels);

    for (has_next = gee_map_iterator_first (it); has_next; has_next = gee_map_iterator_next (it))
    {
        channel = gee_map_iterator_get_value (it);

        g_debug ("Changing %s description to %s",
                 cld_object_get_id (channel),
                 cld_channel_get_desc (CLD_CHANNEL (channel)));

        /* update the analog input values of the xml data in memory */
        value = g_strdup_printf ("%s", cld_channel_get_desc (CLD_CHANNEL (channel)));
        xpath = g_strdup_printf (
                    "//cld/objects/object[@type=\"channel\" and @id=\"%s\"]/property[@name=\"desc\"]",
                    cld_object_get_id (channel));
        cld_xml_config_edit_node_content (xml, xpath, value);
        g_free (value);
        g_free (xpath);
    }
}

static void
update_coefficient_config (CldXmlConfig *xml, gchar *calibration_id, GeeMap *coefficients)
{
    gchar *value, *xpath;
    gboolean has_next;
    CldObject *coefficient;
    GeeMapIterator *it = gee_map_map_iterator (coefficients);

    for (has_next = gee_map_iterator_first (it); has_next; has_next = gee_map_iterator_next (it))
    {
        coefficient = gee_map_iterator_get_value (it);

        /* update the coefficient values of the xml data in memory */
        value = g_strdup_printf ("%.3f", cld_coefficient_get_value (CLD_COEFFICIENT (coefficient)));
        xpath = g_strdup_printf (
                    "//cld/objects/object[@type=\"calibration\" and @id=\"%s\"]/object[@type=\"coefficient\" and @id=\"%s\"]/property[@name=\"value\"]",
                    calibration_id, cld_object_get_id (coefficient));
        cld_xml_config_edit_node_content (xml, xpath, value);
        g_free (value);
        g_free (xpath);
    }
}

static void
update_calibration_config (CldXmlConfig *xml, GeeMap *calibrations)
{
    gchar *value, *xpath;
    gboolean has_next;
    CldObject *calibration;
    GeeMapIterator *it = gee_map_map_iterator (calibrations);
    GeeMap *coefficients;

    for (has_next = gee_map_iterator_first (it); has_next; has_next = gee_map_iterator_next (it))
    {
        calibration = gee_map_iterator_get_value (it);
        coefficients = cld_calibration_get_coefficients (calibration);

        /* update the calibration settings of the xml data in memory */
        value = g_strdup_printf ("%s", cld_calibration_get_units (CLD_CALIBRATION (calibration)));
        xpath = g_strdup_printf (
                    "//cld/objects/object[@type=\"calibration\" and @id=\"%s\"]/property[@name=\"units\"]",
                    cld_object_get_id (calibration));
        cld_xml_config_edit_node_content (xml, xpath, value);
        g_free (value);
        g_free (xpath);

        update_coefficient_config (xml, cld_object_get_id (calibration), coefficients);
    }
}

static void
update_control_config (CldXmlConfig *xml, GeeMap *controls)
{
    gchar *value, *xpath;
    gboolean has_next;
    CldObject *control;
    CldObject *pv;
    CldObject *mv;
    GeeMap *process_values;
    GeeMapIterator *it = gee_map_map_iterator (controls);

    for (has_next = gee_map_iterator_first (it); has_next; has_next = gee_map_iterator_next (it))
    {
        control = gee_map_iterator_get_value (it);
        process_values = cld_pid_get_process_values (CLD_PID (control));

        /* XXX for now assume these never change */
        pv = gee_map_get (process_values, "pv0");
        mv = gee_map_get (process_values, "pv1");
        g_debug ("Control - %s: (PV: %s) & (MV: %s)",
                 cld_object_get_id (control),
                 cld_object_get_id (pv),
                 cld_object_get_id (mv));

        /* update the pid values of the xml data in memory */
        value = g_strdup_printf ("%.6f", cld_pid_get_kp (CLD_PID (control)));
        xpath = g_strdup_printf (
                    "//cld/objects/object[@type=\"control\"]/object[@id=\"%s\"]/property[@name=\"kp\"]",
                    cld_object_get_id (control));
        cld_xml_config_edit_node_content (xml, xpath, value);
        g_free (value);
        g_free (xpath);

        value = g_strdup_printf ("%.6f", cld_pid_get_ki (CLD_PID (control)));
        xpath = g_strdup_printf (
                    "//cld/objects/object[@type=\"control\"]/object[@id=\"%s\"]/property[@name=\"ki\"]",
                    cld_object_get_id (control));
        cld_xml_config_edit_node_content (xml, xpath, value);
        g_free (value);
        g_free (xpath);

        value = g_strdup_printf ("%.6f", cld_pid_get_kd (CLD_PID (control)));
        xpath = g_strdup_printf (
                    "//cld/objects/object[@type=\"control\"]/object[@id=\"%s\"]/property[@name=\"kd\"]",
                    cld_object_get_id (control));
        cld_xml_config_edit_node_content (xml, xpath, value);
        g_free (value);
        g_free (xpath);

        value = g_strdup_printf ("%d", cld_pid_get_dt (CLD_PID (control)));
        xpath = g_strdup_printf (
                    "//cld/objects/object[@type=\"control\"]/object[@id=\"%s\"]/property[@name=\"dt\"]",
                    cld_object_get_id (control));
        cld_xml_config_edit_node_content (xml, xpath, value);
        g_free (value);
        g_free (xpath);

        /* XXX add code to save the process value attributes */
        value = g_strdup_printf ("%s", cld_process_value_get_chref (CLD_PROCESS_VALUE (pv)));
        xpath = g_strdup_printf (
                    "//cld/objects/object[@type=\"control\"]/object[@id=\"%s\"]/object[@id=\"%s\"]",
                    cld_object_get_id (control),
                    cld_object_get_id (pv));
        cld_xml_config_edit_node_attribute (xml, xpath, "chref", value);
        g_free (value);
        g_free (xpath);

        value = g_strdup_printf ("%s", cld_process_value_get_chref (CLD_PROCESS_VALUE (mv)));
        xpath = g_strdup_printf (
                    "//cld/objects/object[@type=\"control\"]/object[@id=\"%s\"]/object[@id=\"%s\"]",
                    cld_object_get_id (control),
                    cld_object_get_id (mv));
        cld_xml_config_edit_node_attribute (xml, xpath, "chref", value);
        g_free (value);
        g_free (xpath);
    }
}

gboolean
cb_btn_save_clicked (GtkWidget *widget, gpointer data)
{
    ApplicationData *app_data = APPLICATION_DATA (data);
    gint response;
    gchar *file;
    GtkWidget *dialog;
    CldXmlConfig *xml = application_data_get_xml (app_data);
    GeeMap *aichannels = application_data_get_ai_channels (app_data);
    GeeMap *calibrations = application_data_get_calibrations (app_data);
    GeeMap *controls = application_data_get_control_loops (app_data);

    /* message box for confirmation */
    file = g_strdup (cld_xml_config_get_file_name (xml));
    dialog = gtk_message_dialog_new (NULL,
                                     GTK_DIALOG_DESTROY_WITH_PARENT,
                                     GTK_MESSAGE_QUESTION,
                                     GTK_BUTTONS_YES_NO,
                                     "Overwrite %s with application preferences?",
                                     file);
    g_free (file);
    response = gtk_dialog_run (GTK_DIALOG (dialog));
    gtk_widget_destroy (dialog);

    /* check the users response and act accordingly */
    switch (response)
    {
        case GTK_RESPONSE_YES:
            update_aichannel_config (xml, aichannels);
            update_calibration_config (xml, calibrations);
            update_control_config (xml, controls);
            /* write the configuration to disc */
            cld_xml_config_save (xml);
            break;
        case GTK_RESPONSE_NO:
            break;
        default:
            break;
    }

    return false;
}

gboolean
cb_btn_chan_clicked (GtkWidget *widget, gpointer data)
{
    ApplicationData *app_data = APPLICATION_DATA (data);
    GtkWidget *dialog = application_settings_dialog_new_with_startup_tab_id (app_data, 2);

    gtk_dialog_run (GTK_DIALOG (dialog));
    gtk_widget_destroy (dialog);

    return false;
}

gboolean
cb_btn_log_toggled (GtkWidget *widget, gpointer data)
{
//    ApplicationData *app_data = APPLICATION_DATA (data);
//    CldBuilder *builder = CLD_BUILDER (application_data_get_builder (APPLICATION_DATA (app_data)));
//    GeeMap *logs = cld_builder_get_logs (builder);
//    GeeMapIterator *it = gee_map_map_iterator (logs);
//    CldLog *log;
//    GtkWidget *img;
//    GtkWidget *lbl;

//    /* XXX usually there will only be a single log file but I'm adding an
//     * outline for the future where multiple logs may be an option */

//    if (gee_map_get_size (logs) > 1)
//        g_debug ("Multiple logs are not yet implemented");

//    /* this would be changed from if -> else if for multi-logs */
//    if (gee_map_get_size (logs) == 1)
//    {
//        g_debug ("Found a single log file.");
//        gee_map_iterator_first (it);
//        log = gee_map_iterator_get_value (it);

//        if (gtk_toggle_tool_button_get_active (GTK_TOGGLE_TOOL_BUTTON (widget)))
//        {
//            /* start logging */
//            cld_log_file_open (CLD_LOG (log));
//            cld_log_run (CLD_LOG (log));

//            g_debug ("Log file id: %s", cld_object_get_id (CLD_OBJECT (log)));

//            /* switch the button contents to the run mode */
//            img = gtk_image_new_from_icon_name ("gtk-media-stop",
//                                                GTK_ICON_SIZE_BUTTON);
//            gtk_tool_button_set_icon_widget (GTK_TOOL_BUTTON (widget), img);
//            lbl = gtk_label_new ("Log Enabled");
//            gtk_tool_button_set_label_widget (GTK_TOOL_BUTTON (widget), lbl);

//            gtk_widget_show (img);
//            gtk_widget_show (lbl);
//            gtk_widget_show (widget);
//        }
//        else
//        {
//            /* stop logging */
//            cld_log_stop (CLD_LOG (log));
//            cld_log_file_mv_and_date (CLD_LOG (log), false);

//            /* switch the button contents to the default */
//            img = gtk_image_new_from_icon_name ("gtk-media-record",
//                                                GTK_ICON_SIZE_BUTTON);
//            gtk_tool_button_set_icon_widget (GTK_TOOL_BUTTON (widget), img);
//            lbl = gtk_label_new ("Log Data");
//            gtk_tool_button_set_label_widget (GTK_TOOL_BUTTON (widget), lbl);

//            gtk_widget_show (img);
//            gtk_widget_show (lbl);
//            gtk_widget_show (widget);
//        }
//    }
//    else
//        /* should change this to a message dialog */
//        g_debug ("No log files have been defined.");

    return false;
}

gboolean
cb_btn_def_toggled (GtkWidget *widget, gpointer data)
{
    gboolean has_next;
    gchar *id, *value, *xpath;
    ApplicationData *app_data = APPLICATION_DATA (data);
    CldXmlConfig *xml = application_data_get_xml (app_data);
    GeeMap *channels = application_data_get_ai_channels (app_data);
    GeeMapIterator *it = gee_map_map_iterator (channels);
    CldAIChannel *channel;
    CldCalibration *cal;

    if (gtk_toggle_tool_button_get_active (GTK_TOGGLE_TOOL_BUTTON (widget)))
    {
        for (has_next = gee_map_iterator_first (it); has_next; has_next = gee_map_iterator_next (it))
        {
            channel = gee_map_iterator_get_value (it);
            printf ("Found channel: %s reading %f\n",
                    cld_object_get_id (CLD_OBJECT (channel)),
                    cld_ai_channel_get_scaled_value (channel));
            cal = cld_ai_channel_get_calibration (channel);
            printf ("Found calibration: %s units %s\n",
                    cld_object_get_id (CLD_OBJECT (cal)),
                    cld_calibration_get_units (cal));

            cld_calibration_set_units (cal, "Volts");

            gboolean has_next_coefficient;
            GeeMap *coefficients = cld_calibration_get_coefficients (cal);
            GeeMapIterator *it_coefficients = gee_map_map_iterator (coefficients);
            CldCoefficient *coefficient;

            for (has_next_coefficient = gee_map_iterator_first (it_coefficients);
                 has_next_coefficient;
                 has_next_coefficient = gee_map_iterator_next (it_coefficients))
            {
                coefficient = gee_map_iterator_get_value (it_coefficients);
                printf ("Found coefficient: %s\n", cld_object_get_id (CLD_OBJECT (coefficient)));
                if (cld_coefficient_get_n (coefficient) == 1)
                    cld_coefficient_set_value (coefficient, 1.0);
                else
                    cld_coefficient_set_value (coefficient, 0.0);
            }
        }
    }
    else
    {
        /* reload channel scaling from configuration file */
        for (has_next = gee_map_iterator_first (it); has_next; has_next = gee_map_iterator_next (it))
        {
            channel = gee_map_iterator_get_value (it);
            printf ("Found channel: %s reading %f\n",
                    cld_object_get_id (CLD_OBJECT (channel)),
                    cld_ai_channel_get_scaled_value (channel));
            cal = cld_ai_channel_get_calibration (channel);
            printf ("Found calibration: %s units %s\n",
                    cld_object_get_id (CLD_OBJECT (cal)),
                    cld_calibration_get_units (cal));
            id = cld_object_get_id (CLD_OBJECT (cal));

            /* XXX this should go into CLD as cld_object_reload_xml_config */

            /* reload the units */
            xpath = g_strdup_printf (
                        "//cld/objects/object[@id=\"%s\"]/property[@name=\"units\"]",
                        id);
            value = g_strdup (cld_xml_config_value_at_xpath (xml, xpath));
            printf ("Printing @ %s: value: %s\n", xpath, value);
            cld_calibration_set_units (cal, g_strdup (value));
            g_free (xpath);
            g_free (value);

            gint n;
            gboolean has_next_coefficient;
            GeeMap *coefficients = cld_calibration_get_coefficients (cal);
            GeeMapIterator *it_coefficients = gee_map_map_iterator (coefficients);
            CldCoefficient *coefficient;

            /* reload the coefficients */
            for (has_next_coefficient = gee_map_iterator_first (it_coefficients);
                 has_next_coefficient;
                 has_next_coefficient = gee_map_iterator_next (it_coefficients))
            {
                coefficient = gee_map_iterator_get_value (it_coefficients);
                n = cld_coefficient_get_n (coefficient);
                printf ("Found coefficient: %s\n", cld_object_get_id (CLD_OBJECT (coefficient)));
                xpath = g_strdup_printf (
                            "//cld/objects/object[@id=\"%s\"]/object[@id=\"%s\"]/property[@name=\"value\"]",
                            id, cld_object_get_id (CLD_OBJECT (coefficient)), n);
                value = g_strdup (cld_xml_config_value_at_xpath (xml, xpath));
                printf ("Printing @ %s: value: %s\n", xpath, value);
                cld_coefficient_set_value (coefficient, atof (value));
                g_free (xpath);
                g_free (value);
            }
        }
    }

    return false;
}
