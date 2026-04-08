import Toybox.Graphics;
import Toybox.Lang;

class HeartTooLayout {

    static function resolve(fieldWidth as Numeric, fieldHeight as Numeric, numberFontHeight as Numeric) as Dictionary {
        var fontDefinitions = [Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_LARGE, Graphics.FONT_MEDIUM, Graphics.FONT_TINY];
        var locationCoordinates;

        switch (fieldWidth) {
            case 122:
                locationCoordinates = getEdgeNarrowLayout();
                if (numberFontHeight == 48) {
                    fontDefinitions = [Graphics.FONT_NUMBER_HOT, Graphics.FONT_LARGE, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL];
                }
                break;

            case 246:
                locationCoordinates = getEdgeWideLayout();
                break;

            case 140:
                locationCoordinates = getEdgeStandardLayout();
                if (numberFontHeight == 48) {
                    fontDefinitions = [Graphics.FONT_NUMBER_HOT, Graphics.FONT_LARGE, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL];
                }
                break;

            case 282:
                if (numberFontHeight != 48) {
                    locationCoordinates = getEdgeStandardLayout();
                } else if (fieldHeight > 100) {
                    locationCoordinates = getEdge1040LayoutTall();
                    fontDefinitions = [Graphics.FONT_NUMBER_HOT, Graphics.FONT_LARGE, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL];
                } else {
                    locationCoordinates = getEdge1040LayoutCompact();
                    fontDefinitions = [Graphics.FONT_NUMBER_HOT, Graphics.FONT_LARGE, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL];
                }
                break;

            default:
                locationCoordinates = getEdgeStandardLayout();
        }

        return {
            :coordinates => locationCoordinates,
            :fontDefinitions => fontDefinitions
        };
    }

    static function getEdgeNarrowLayout() as Array<Numeric> {
        return [
            122,
            1,
            87, 21,
            68, 21,
            119, 17,
            120, 12,
            91, 40,
            71, 38,
            4,
            9
        ];
    }

    static function getEdgeStandardLayout() as Array<Numeric> {
        return [
            140,
            2,
            100, 38,
            78, 38,
            136, 25,
            138, 17,
            104, 56,
            82, 56,
            6,
            14
        ];
    }

    static function getEdge1040LayoutTall() as Array<Numeric> {
        return [
            140,
            2,
            115, 25,
            235, 45,
            118, 58,
            242, 58,
            245, 15,
            141, 45,
            6,
            14
        ];
    }

    static function getEdge1040LayoutCompact() as Array<Numeric> {
        return [
            140,
            2,
            115, 25,
            235, 45,
            118, 58,
            240, 65,
            245, 33,
            141, 45,
            6,
            14
        ];
    }

    static function getEdgeWideLayout() as Array<Numeric> {
        return [
            122,
            1,
            84, 21,
            208, 21,
            88, 38,
            212, 43,
            215, 18,
            122, 31,
            4,
            9
        ];
    }
}

