// This EA calls a custom indicator.

// Initialization function
void OnInit() {
    double get_volume;
    double get_volume_ma;

    string cus_symbol   = NULL; // NULL means the current symbol displayed on the main window.
    int    cus_period   = PERIOD_CURRENT;
    string cus_indname  = "test_ind"; // The name of the custom indicator
    int    input_param1 = 10;         // The input parameter of the custom indicator
    int    shift_index;
    int    icount;

    for (icount = 0; icount < 20; icount++) {
        shift_index = icount;

        get_volume = iCustom( // Calling the custom indicator
            cus_symbol,
            cus_period,
            cus_indname,
            input_param1,
            0,          // The index of indicator buffer
            shift_index // 何本前のローソク足を使用するか
        );

        get_volume_ma = iCustom(
            cus_symbol,
            cus_period,
            cus_indname,
            input_param1,
            1,          // The index of indicator buffer
            shift_index // 何本前のローソク足を使用するか
        );

        printf(
            "\"%s\"custom indicator (input param1 = %d)(%s,%d), volume[%d]=%g, averaged volume[%d]=%g",
            cus_indname,
            input_param1,
            cus_symbol,
            cus_period,
            shift_index,
            get_volume,
            shift_index,
            get_volume_ma
        );
    }
}