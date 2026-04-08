import Toybox.Lang;

//! ==================== HeartToo Zone Formulas ====================
//! FTP-based power zone threshold multipliers for different cycling training systems

module HeartTooZoneFormulas {

    //! ==================== Zone Formula 1 Multipliers ====================
    //! Standard Coggan power zones based on FTP percentage
    public const FORMULA_1_MULTIPLIERS as Array<Numeric> = [0.59, 0.79, 0.9, 1.04, 1.2, 1.5];

    //! ==================== Zone Formula 2 Multipliers ====================
    //! Alternative cycling training zone system
    public const FORMULA_2_MULTIPLIERS as Array<Numeric> = [0.55, 0.75, 0.90, 1.05, 1.2, 1.5];

    //! ==================== Zone Formula Default Multipliers ====================
    //! Used when calculation type is not recognized
    public const FORMULA_DEFAULT_MULTIPLIERS as Array<Numeric> = [0.55, 0.75, 0.9, 1.05, 1.2, 1.5];

    //! ==================== Default Zone Thresholds ====================
    //! Static thresholds used when no FTP is available
    public const DEFAULT_ZONE_THRESHOLDS as Array<Number> = [110, 150, 180, 210, 240, 300];

    //! Get multipliers for a specific FTP formula type
    //! @param formulaType The formula type (1, 2, or default)
    //! @return Array of 6 multipliers for zone threshold calculation
    function getMultipliersForFormula(formulaType as Numeric) as Array<Numeric> {
        switch(formulaType) {
            case 1:
                return FORMULA_1_MULTIPLIERS;
            case 2:
                return FORMULA_2_MULTIPLIERS;
            default:
                return FORMULA_DEFAULT_MULTIPLIERS;
        }
    }

}

