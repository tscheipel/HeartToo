import Toybox.Graphics;
import Toybox.Lang;

//! ==================== HeartToo Application Constants ====================
//! Centralized constant definitions for layout indices, text justification, and display modes

module HeartTooConstants {

    //! ==================== Layout Configuration Index Constants ====================
    //! These constants replace magic array indices, making code self-documenting:
    //! Instead of: locationCoordinates[2], use: locationCoordinates[HeartTooConstants.INDEX_PRIMARY_POWER_X]

    public const INDEX_SCREEN_WIDTH_REFERENCE = 0;    // Reference width for this layout
    public const INDEX_TITLE_Y = 1;                    // Title Y position
    public const INDEX_PRIMARY_POWER_X = 2;            // Primary power value X coordinate
    public const INDEX_PRIMARY_POWER_Y = 3;            // Primary power value Y coordinate
    public const INDEX_SECONDARY_POWER_X = 4;          // Secondary power value X coordinate
    public const INDEX_SECONDARY_POWER_Y = 5;          // Secondary power value Y coordinate
    public const INDEX_PRIMARY_METRIC_X = 6;           // Primary metric label X coordinate
    public const INDEX_PRIMARY_METRIC_Y = 7;           // Primary metric label Y coordinate
    public const INDEX_RESERVED_X = 8;                 // Reserved for future layout elements
    public const INDEX_RESERVED_Y = 9;                 // Reserved for future layout elements
    public const INDEX_SECONDARY_METRIC_X = 10;        // Secondary metric label X coordinate
    public const INDEX_SECONDARY_METRIC_Y = 11;        // Secondary metric label Y coordinate
    public const INDEX_TERTIARY_METRIC_X = 12;         // Tertiary metric label X coordinate
    public const INDEX_TERTIARY_METRIC_Y = 13;         // Tertiary metric label Y coordinate
    public const INDEX_ZONE_MARGIN = 14;               // Left/right margin for power zone bar display
    public const INDEX_NORMALIZED_GRID_HEIGHT = 15;    // Maximum height for normalized power histogram

    //! ==================== Text Justification Constants ====================

    public const TEXT_RIGHT = Graphics.TEXT_JUSTIFY_RIGHT;
    public const TEXT_LEFT = Graphics.TEXT_JUSTIFY_LEFT;
    public const TEXT_RIGHT_VCENTER = Graphics.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER;
    public const TEXT_LEFT_VCENTER = Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER;

    //! ==================== Display Mode Constants ====================

    public const THEME_NONE = 0;
    public const THEME_RED = 1;
    public const THEME_RED_INVERT = 2;
    public const THEME_ZONES = 3;
    public const INDICATE_HIGH = 4;
    public const INDICATE_LOW = 5;
    public const INDICATE_NORMAL = 6;

}

