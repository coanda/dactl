#include "common.h"

#include "libdactl.h"
#include "callbacks.h"

/*
 *static void
 *update_aichannel_config (CldXmlConfig *xml, GeeMap *channels)
 *{
 *    gchar *value, *xpath;
 *    gboolean has_next;
 *    CldObject *channel;
 *    GeeMapIterator *it = gee_map_map_iterator (channels);
 *
 *    for (has_next = gee_map_iterator_first (it); has_next; has_next = gee_map_iterator_next (it))
 *    {
 *        channel = gee_map_iterator_get_value (it);
 *
 *        g_debug ("Changing %s description to %s",
 *                 cld_object_get_id (channel),
 *                 cld_channel_get_desc (CLD_CHANNEL (channel)));
 *
 *        [> update the analog input values of the xml data in memory <]
 *        value = g_strdup_printf ("%s", cld_channel_get_desc (CLD_CHANNEL (channel)));
 *        xpath = g_strdup_printf (
 *                    "//cld/cld:objects/cld:object[@type=\"channel\" and @id=\"%s\"]/cld:property[@name=\"desc\"]",
 *                    cld_object_get_id (channel));
 *        cld_xml_config_edit_node_content (xml, xpath, value);
 *        g_free (value);
 *        g_free (xpath);
 *    }
 *}
 */

/*
 *static void
 *update_coefficient_config (CldXmlConfig *xml, gchar *calibration_id, GeeMap *coefficients)
 *{
 *    gchar *value, *xpath;
 *    gboolean has_next;
 *    CldObject *coefficient;
 *    GeeMapIterator *it = gee_map_map_iterator (coefficients);
 *
 *    for (has_next = gee_map_iterator_first (it); has_next; has_next = gee_map_iterator_next (it))
 *    {
 *        coefficient = gee_map_iterator_get_value (it);
 *
 *        [> update the coefficient values of the xml data in memory <]
 *        value = g_strdup_printf ("%.4f", cld_coefficient_get_value (CLD_COEFFICIENT (coefficient)));
 *        xpath = g_strdup_printf (
 *                    "//cld/cld:objects/cld:object[@type=\"calibration\" and @id=\"%s\"]/cld:object[@type=\"coefficient\" and @id=\"%s\"]/cld:property[@name=\"value\"]",
 *                    calibration_id, cld_object_get_id (coefficient));
 *        cld_xml_config_edit_node_content (xml, xpath, value);
 *        g_free (value);
 *        g_free (xpath);
 *    }
 *}
 */

/*
 *static void
 *update_calibration_config (CldXmlConfig *xml, GeeMap *calibrations)
 *{
 *    gchar *value, *xpath;
 *    gboolean has_next;
 *    CldObject *calibration;
 *    GeeMapIterator *it = gee_map_map_iterator (calibrations);
 *    GeeMap *coefficients;
 *
 *    for (has_next = gee_map_iterator_first (it); has_next; has_next = gee_map_iterator_next (it))
 *    {
 *        calibration = gee_map_iterator_get_value (it);
 *        coefficients = cld_calibration_get_coefficients (calibration);
 *
 *        [> update the calibration settings of the xml data in memory <]
 *        value = g_strdup_printf ("%s", cld_calibration_get_units (CLD_CALIBRATION (calibration)));
 *        xpath = g_strdup_printf (
 *                    "//cld/cld:objects/cld:object[@type=\"calibration\" and @id=\"%s\"]/cld:property[@name=\"units\"]",
 *                    cld_object_get_id (calibration));
 *        cld_xml_config_edit_node_content (xml, xpath, value);
 *        g_free (value);
 *        g_free (xpath);
 *
 *        update_coefficient_config (xml, cld_object_get_id (calibration), coefficients);
 *    }
 *}
 */

/*
 *static void
 *update_control_config (CldXmlConfig *xml, GeeMap *controls)
 *{
 *    gchar *value, *xpath;
 *    gboolean has_next;
 *    CldObject *control;
 *    CldObject *pv;
 *    CldObject *mv;
 *    GeeMap *process_values;
 *    GeeMapIterator *it = gee_map_map_iterator (controls);
 *
 *    for (has_next = gee_map_iterator_first (it); has_next; has_next = gee_map_iterator_next (it))
 *    {
 *        control = gee_map_iterator_get_value (it);
 *        process_values = cld_pid_get_process_values (CLD_PID (control));
 *
 *        [> XXX for now assume these never change <]
 *        pv = gee_map_get (process_values, "pv0");
 *        mv = gee_map_get (process_values, "pv1");
 *        g_debug ("Control - %s: (PV: %s) & (MV: %s)",
 *                 cld_object_get_id (control),
 *                 cld_object_get_id (pv),
 *                 cld_object_get_id (mv));
 *
 *        [> update the pid values of the xml data in memory <]
 *        value = g_strdup_printf ("%.6f", cld_pid_get_kp (CLD_PID (control)));
 *        xpath = g_strdup_printf (
 *                    "//cld/cld:objects/cld:object[@type=\"control\"]/cld:object[@id=\"%s\"]/cld:property[@name=\"kp\"]",
 *                    cld_object_get_id (control));
 *        cld_xml_config_edit_node_content (xml, xpath, value);
 *        g_free (value);
 *        g_free (xpath);
 *
 *        value = g_strdup_printf ("%.6f", cld_pid_get_ki (CLD_PID (control)));
 *        xpath = g_strdup_printf (
 *                    "//cld/cld:objects/cld:object[@type=\"control\"]/cld:object[@id=\"%s\"]/cld:property[@name=\"ki\"]",
 *                    cld_object_get_id (control));
 *        cld_xml_config_edit_node_content (xml, xpath, value);
 *        g_free (value);
 *        g_free (xpath);
 *
 *        value = g_strdup_printf ("%.6f", cld_pid_get_kd (CLD_PID (control)));
 *        xpath = g_strdup_printf (
 *                    "//cld/cld:objects/cld:object[@type=\"control\"]/cld:object[@id=\"%s\"]/cld:property[@name=\"kd\"]",
 *                    cld_object_get_id (control));
 *        cld_xml_config_edit_node_content (xml, xpath, value);
 *        g_free (value);
 *        g_free (xpath);
 *
 *        value = g_strdup_printf ("%d", cld_pid_get_dt (CLD_PID (control)));
 *        xpath = g_strdup_printf (
 *                    "//cld/cld:objects/cld:object[@type=\"control\"]/cld:object[@id=\"%s\"]/cld:property[@name=\"dt\"]",
 *                    cld_object_get_id (control));
 *        cld_xml_config_edit_node_content (xml, xpath, value);
 *        g_free (value);
 *        g_free (xpath);
 *
 *        [> XXX add code to save the process value attributes <]
 *        value = g_strdup_printf ("%s", cld_process_value_get_chref (CLD_PROCESS_VALUE (pv)));
 *        xpath = g_strdup_printf (
 *                    "//cld/cld:objects/cld:object[@type=\"control\"]/cld:object[@id=\"%s\"]/cld:object[@id=\"%s\"]",
 *                    cld_object_get_id (control),
 *                    cld_object_get_id (pv));
 *        cld_xml_config_edit_node_attribute (xml, xpath, "chref", value);
 *        g_free (value);
 *        g_free (xpath);
 *
 *        value = g_strdup_printf ("%s", cld_process_value_get_chref (CLD_PROCESS_VALUE (mv)));
 *        xpath = g_strdup_printf (
 *                    "//cld/cld:objects/cld:object[@type=\"control\"]/cld:object[@id=\"%s\"]/cld:object[@id=\"%s\"]",
 *                    cld_object_get_id (control),
 *                    cld_object_get_id (mv));
 *        cld_xml_config_edit_node_attribute (xml, xpath, "chref", value);
 *        g_free (value);
 *        g_free (xpath);
 *    }
 *}
 */

/*
 *static void
 *update_module_config (CldXmlConfig *xml, GeeMap *modules)
 *{
 *    gchar *value, *xpath;
 *    gboolean has_next;
 *    CldObject *module;
 *    GeeMapIterator *it = gee_map_map_iterator (modules);
 *
 *    for (has_next = gee_map_iterator_first (it); has_next; has_next = gee_map_iterator_next (it))
 *    {
 *        module = gee_map_iterator_get_value (it);
 *
 *        [> XXX this should be fixed - should use type check instead <]
 *        if (g_strcmp0 (cld_object_get_id (CLD_OBJECT (module)), "vm0") == 0)
 *        {
 *            [> update the pid values of the xml data in memory <]
 *            value = g_strdup_printf ("%s", cld_velmex_module_get_program (CLD_VELMEX_MODULE (module)));
 *            xpath = g_strdup_printf (
 *                        "//cld/cld:objects/cld:object[@type=\"module\" and @id=\"%s\"]/cld:property[@name=\"program\"]",
 *                        cld_object_get_id (module));
 *            g_message ("%s \n %s", value, xpath);
 *            cld_xml_config_edit_node_content (xml, xpath, value);
 *            g_free (value);
 *            g_free (xpath);
 *        }
 *    }
 *}
 */

/*
 *static void
 *update_log_config (CldXmlConfig *xml, GeeMap *logs)
 *{
 *    gchar *value, *xpath;
 *    gboolean has_next;
 *    CldObject *log;
 *    GeeMapIterator *it = gee_map_map_iterator (logs);
 *
 *    for (has_next = gee_map_iterator_first (it); has_next; has_next = gee_map_iterator_next (it))
 *    {
 *        log = gee_map_iterator_get_value (it);
 *
 *        [> update the log information of the xml data in memory <]
 *        value = g_strdup_printf ("%s", cld_log_get_name (CLD_LOG (log)));
 *        xpath = g_strdup_printf (
 *                    "//cld/cld:objects/cld:object[@type=\"log\" and @id=\"%s\"]/cld:property[@name=\"title\"]",
 *                    cld_object_get_id (log));
 *        cld_xml_config_edit_node_content (xml, xpath, value);
 *        g_free (value);
 *        g_free (xpath);
 *
 *        value = g_strdup_printf ("%s", cld_log_get_path (CLD_LOG (log)));
 *        xpath = g_strdup_printf (
 *                    "//cld/cld:objects/cld:object[@type=\"log\" and @id=\"%s\"]/cld:property[@name=\"path\"]",
 *                    cld_object_get_id (log));
 *        cld_xml_config_edit_node_content (xml, xpath, value);
 *        g_free (value);
 *        g_free (xpath);
 *
 *        value = g_strdup_printf ("%s", cld_log_get_file (CLD_LOG (log)));
 *        xpath = g_strdup_printf (
 *                    "//cld/cld:objects/cld:object[@type=\"log\" and @id=\"%s\"]/cld:property[@name=\"file\"]",
 *                    cld_object_get_id (log));
 *        cld_xml_config_edit_node_content (xml, xpath, value);
 *        g_free (value);
 *        g_free (xpath);
 *
 *        value = g_strdup_printf ("%s", cld_log_get_date_format (CLD_LOG (log)));
 *        xpath = g_strdup_printf (
 *                    "//cld/cld:objects/cld:object[@type=\"log\" and @id=\"%s\"]/cld:property[@name=\"format\"]",
 *                    cld_object_get_id (log));
 *        cld_xml_config_edit_node_content (xml, xpath, value);
 *        g_free (value);
 *        g_free (xpath);
 *
 *        value = g_strdup_printf ("%.3f", cld_log_get_rate (CLD_LOG (log)));
 *        xpath = g_strdup_printf (
 *                    "//cld/cld:objects/cld:object[@type=\"log\" and @id=\"%s\"]/cld:property[@name=\"rate\"]",
 *                    cld_object_get_id (log));
 *        cld_xml_config_edit_node_content (xml, xpath, value);
 *        g_free (value);
 *        g_free (xpath);
 *    }
 *}
 */

/*
 *gboolean
 *cb_btn_save_clicked (GtkWidget *widget, gpointer data)
 *{
 *    ApplicationModel *app_model = APPLICATION_MODEL (data);
 *    gint response;
 *    gchar *file;
 *    GtkWidget *dialog;
 *    ApplicationConfig *config = application_model_get_config (app_model);
 *    CldXmlConfig *xml = application_model_get_xml (app_model);
 *    CldBuilder *builder = application_model_get_builder (app_model);
 *    GeeMap *aichannels = application_model_get_ai_channels (app_model);
 *    GeeMap *calibrations = application_model_get_calibrations (app_model);
 *    GeeMap *controls = application_model_get_control_loops (app_model);
 *    GeeMap *modules = application_model_get_modules (app_model);
 *    GeeMap *logs = cld_builder_get_logs (builder);
 *
 *    [> message box warning if <defaults> is set <]
 *    if (application_model_get_def_enabled (app_model)) {
 *
 *        dialog = gtk_message_dialog_new (NULL,
 *                                         GTK_DIALOG_DESTROY_WITH_PARENT,
 *                                         GTK_MESSAGE_QUESTION,
 *                                         GTK_BUTTONS_YES_NO,
 *                                         "Calibrations are set to DEFAULT!\nDo you still want to save?");
 *        g_free (file);
 *        response = gtk_dialog_run (GTK_DIALOG (dialog));
 *        gtk_widget_destroy (dialog);
 *
 *        switch (response)
 *        {
 *            case GTK_RESPONSE_YES:
 *                break;
 *            case GTK_RESPONSE_NO:
 *                return false;
 *            default:
 *                break;
 *        }
 *    }
 *
 *    [> message box for confirmation <]
 *    file = g_strdup (application_config_get_file_name (config));
 *    dialog = gtk_message_dialog_new (NULL,
 *                                     GTK_DIALOG_DESTROY_WITH_PARENT,
 *                                     GTK_MESSAGE_QUESTION,
 *                                     GTK_BUTTONS_YES_NO,
 *                                     "Overwrite %s with application preferences?",
 *                                     file);
 *    g_free (file);
 *    response = gtk_dialog_run (GTK_DIALOG (dialog));
 *    gtk_widget_destroy (dialog);
 *
 *    [> check the users response and act accordingly <]
 *    switch (response)
 *    {
 *        case GTK_RESPONSE_YES:
 *            update_aichannel_config (xml, aichannels);
 *            update_calibration_config (xml, calibrations);
 *            update_control_config (xml, controls);
 *            update_module_config (xml, modules);
 *            update_log_config (xml, logs);
 *            [> write the configuration to disc <]
 *            application_config_set_xml_node (config, "//dactl/cld:objects",
 *                                             cld_xml_config_get_node (xml, "//cld/cld:objects"));
 *            application_config_save (config);
 *            break;
 *        case GTK_RESPONSE_NO:
 *            break;
 *        default:
 *            break;
 *    }
 *
 *    return false;
 *}
 */

//gboolean
//cb_btn_chan_clicked (GtkWidget *widget, gpointer data)
//{
//    ApplicationModel *app_model = APPLICATION_MODEL (data);
//    GtkWidget *dialog = application_settings_dialog_new_with_startup_tab_id (app_model, 2);
//
//    gtk_dialog_run (GTK_DIALOG (dialog));
////    gtk_widget_destroy (dialog);
//
//    return false;
//}

/*
 *gboolean
 *cb_btn_quit_clicked (GtkWidget *widget, gpointer data)
 *{
 *    ApplicationModel *app_model = APPLICATION_MODEL (data);
 *    //GraphicalView *ui_data = GRAPHICAL_VIEW (application_model_get_ui (app_model));
 *    int response;
 *    GtkWidget *dialog;
 *
 *    dialog = gtk_message_dialog_new (NULL, [>GTK_WINDOW (graphical_view_get_main_window (ui_data)),<]
 *                                     GTK_DIALOG_DESTROY_WITH_PARENT,
 *                                     GTK_MESSAGE_QUESTION,
 *                                     GTK_BUTTONS_YES_NO,
 *                                     "Are you sure you want to quit?");
 *
 *    gtk_widget_show_all (dialog);
 *    response = gtk_dialog_run (GTK_DIALOG (dialog));
 *    gtk_widget_destroy (dialog);
 *
 *    switch (response)
 *    {
 *        case GTK_RESPONSE_NO:
 *            break;
 *        case GTK_RESPONSE_YES:
 *            gtk_main_quit ();
 *            break;
 *        default:
 *            break;
 *    }
 *
 *    return false;
 *}
 */

//gboolean
//cb_btn_pref_clicked (GtkWidget *widget, gpointer data)
//{
//    ApplicationModel *app_model = APPLICATION_MODEL (data);
//    GtkWidget *dialog = application_settings_dialog_new_with_startup_tab_id (app_model, 0);
//
//    gtk_dialog_run (GTK_DIALOG (dialog));
//    gtk_widget_destroy (dialog);
//
//    return false;
//}

/*
 *gboolean
 *cb_btn_def_toggled (GtkWidget *widget, gpointer data)
 *{
 *    gboolean has_next;
 *    gchar *id, *value, *xpath;
 *    ApplicationModel *app_model = APPLICATION_MODEL (data);
 *    CldXmlConfig *xml = application_model_get_xml (app_model);
 *    GeeMap *channels = application_model_get_ai_channels (app_model);
 *    GeeMapIterator *it = gee_map_map_iterator (channels);
 *    CldAIChannel *channel;
 *    CldCalibration *cal;
 *
 *    if (gtk_toggle_tool_button_get_active (GTK_TOGGLE_TOOL_BUTTON (widget)))
 *    {
 *        application_model_set_def_enabled (app_model , true);
 *        for (has_next = gee_map_iterator_first (it); has_next; has_next = gee_map_iterator_next (it))
 *        {
 *            channel = gee_map_iterator_get_value (it);
 *            printf ("Found channel: %s reading %f\n",
 *                    cld_object_get_id (CLD_OBJECT (channel)),
 *                    cld_scalable_channel_get_scaled_value (channel));
 *            cal = cld_scalable_channel_get_calibration (channel);
 *            printf ("Found calibration: %s units %s\n",
 *                    cld_object_get_id (CLD_OBJECT (cal)),
 *                    cld_calibration_get_units (cal));
 *
 *            cld_calibration_set_units (cal, "Volts");
 *
 *            gboolean has_next_coefficient;
 *            GeeMap *coefficients = cld_calibration_get_coefficients (cal);
 *            GeeMapIterator *it_coefficients = gee_map_map_iterator (coefficients);
 *            CldCoefficient *coefficient;
 *
 *            for (has_next_coefficient = gee_map_iterator_first (it_coefficients);
 *                 has_next_coefficient;
 *                 has_next_coefficient = gee_map_iterator_next (it_coefficients))
 *            {
 *                coefficient = gee_map_iterator_get_value (it_coefficients);
 *                printf ("Found coefficient: %s\n", cld_object_get_id (CLD_OBJECT (coefficient)));
 *                if (cld_coefficient_get_n (coefficient) == 1)
 *                    cld_coefficient_set_value (coefficient, 1.0);
 *                else
 *                    cld_coefficient_set_value (coefficient, 0.0);
 *            }
 *        }
 *    }
 *    else
 *    {
 *        application_model_set_def_enabled (app_model , false);
 *        [> reload channel scaling from configuration file <]
 *        for (has_next = gee_map_iterator_first (it); has_next; has_next = gee_map_iterator_next (it))
 *        {
 *            channel = gee_map_iterator_get_value (it);
 *            printf ("Found channel: %s reading %f\n",
 *                    cld_object_get_id (CLD_OBJECT (channel)),
 *                    cld_scalable_channel_get_scaled_value (channel));
 *            cal = cld_scalable_channel_get_calibration (channel);
 *            printf ("Found calibration: %s units %s\n",
 *                    cld_object_get_id (CLD_OBJECT (cal)),
 *                    cld_calibration_get_units (cal));
 *            id = cld_object_get_id (CLD_OBJECT (cal));
 *
 *            [> XXX this should go into CLD as cld_object_reload_xml_config <]
 *
 *            [> reload the units <]
 *            xpath = g_strdup_printf (
 *                        "//cld/cld:objects/cld:object[@id=\"%s\"]/cld:property[@name=\"units\"]",
 *                        id);
 *            value = g_strdup (cld_xml_config_value_at_xpath (xml, xpath));
 *            printf ("Printing @ %s: value: %s\n", xpath, value);
 *            cld_calibration_set_units (cal, g_strdup (value));
 *            g_free (xpath);
 *            g_free (value);
 *
 *            gint n;
 *            gboolean has_next_coefficient;
 *            GeeMap *coefficients = cld_calibration_get_coefficients (cal);
 *            GeeMapIterator *it_coefficients = gee_map_map_iterator (coefficients);
 *            CldCoefficient *coefficient;
 *
 *            [> reload the coefficients <]
 *            for (has_next_coefficient = gee_map_iterator_first (it_coefficients);
 *                 has_next_coefficient;
 *                 has_next_coefficient = gee_map_iterator_next (it_coefficients))
 *            {
 *                coefficient = gee_map_iterator_get_value (it_coefficients);
 *                n = cld_coefficient_get_n (coefficient);
 *                printf ("Found coefficient: %s\n", cld_object_get_id (CLD_OBJECT (coefficient)));
 *                xpath = g_strdup_printf (
 *                            "//cld/cld:objects/cld:object[@id=\"%s\"]/cld:object[@id=\"%s\"]/cld:property[@name=\"value\"]",
 *                            id, cld_object_get_id (CLD_OBJECT (coefficient)), n);
 *                value = g_strdup (cld_xml_config_value_at_xpath (xml, xpath));
 *                printf ("Printing @ %s: value: %s\n", xpath, value);
 *                cld_coefficient_set_value (coefficient, atof (value));
 *                g_free (xpath);
 *                g_free (value);
 *            }
 *        }
 *    }
 *
 *    return false;
 *}
 */
