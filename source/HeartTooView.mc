import Toybox.Activity;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.WatchUi;

import HeartTooConstants;
import HeartTooSettings;
import HeartTooZones;
import HeartTooRenderer;

class HeartTooView extends WatchUi.DataField {

    hidden var currentHeartRate as Numeric;
    hidden var averageHeartRate as Numeric;
    hidden var maxHeartRate as Numeric;
    hidden var nSecondHeartRate as Numeric;

    hidden var currentHeartZone as Numeric;
    hidden var heartZoneDecimal as Numeric;
    hidden var heartArray as Array<Float> = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    hidden var heartZoneThreshold as Array<Number> = [117, 144, 160, 171, 189, 192];
    hidden var heartZoneColor as Array<Number>;

    hidden var arrHeart as Array<Numeric> or Null;

    hidden var locationCoordinates as Array<Numeric>;
    hidden var fontDefinitions as Array<FontDefinition>;
    hidden var width as Numeric;
    hidden var height as Numeric;
    hidden var fontHeight as Numeric;

    hidden var nSecondInterval as Numeric = 3;
    hidden var averageMode as Numeric = 0;
    hidden var preferredSmallFont as Boolean = false;
    hidden var showHeartZoneBar as Boolean = true;
    hidden var showHeartZoneHistory as Boolean = false;
    hidden var drawCurrentZone as Boolean = true;
    hidden var drawLabels as Boolean = true;
    hidden var showAverageHeartRate as Boolean = true;

    hidden var smallFont as Boolean = false;
    hidden var normalizeOn = false as Boolean;
    hidden var zoneLabelOffsetX = 0 as Numeric;
    hidden var heartZoneBarHeight as Numeric = 0;
    hidden var heartZoneIndexHeight as Numeric = 0;

    hidden var labelAvg;
    hidden var labelMax;
    hidden var metric;
    hidden var title;
    hidden var modeShortTermHeart as Array<String> = new [4] as Array<String>;
    hidden var modeAverageHeart as Array<String> = new [2] as Array<String>;

    function initialize() {
        DataField.initialize();

        currentHeartRate = 0;
        averageHeartRate = 0;
        maxHeartRate = 0;
        nSecondHeartRate = 0.0f;
        currentHeartZone = 0;
        heartZoneDecimal = 0.0f;

        locationCoordinates = [140, 2, 100, 38, 78, 38, 136, 25, 138, 17, 104, 56, 82, 56, 6, 14];
        fontDefinitions = [Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_LARGE, Graphics.FONT_MEDIUM, Graphics.FONT_TINY];
        width = 140;
        height = 92;
        fontHeight = 47;

        arrHeart = null;
        heartZoneColor = HeartTooZones.initializeZoneColors();

        labelAvg = loadResource(Rez.Strings.labelAvg);
        labelMax = loadResource(Rez.Strings.labelMax);
        metric = loadResource(Rez.Strings.metric);
        title = loadResource(Rez.Strings.title);

        initProperties();
        readModeShortTermHeart();
        readModeAverageHeart();
    }

    function initProperties() {
        var displaySettings = {} as Dictionary;
        HeartTooSettings.loadAll(displaySettings);

        preferredSmallFont = displaySettings[:preferredSmallFont] as Boolean;
        smallFont = preferredSmallFont;
        showHeartZoneBar = displaySettings[:showHeartZoneBar] as Boolean;
        heartZoneBarHeight = displaySettings[:heartZoneBarHeight] as Numeric;
        heartZoneIndexHeight = displaySettings[:heartZoneIndexHeight] as Numeric;
        showHeartZoneHistory = displaySettings[:showHeartZoneHistory] as Boolean;
        drawLabels = displaySettings[:drawLabels] as Boolean;
        drawCurrentZone = displaySettings[:drawCurrentZone] as Boolean;
        nSecondInterval = displaySettings[:nSecondInterval] as Numeric;
        averageMode = displaySettings[:averageMode] as Numeric;
        showAverageHeartRate = displaySettings[:showAverageHeartRate] as Boolean;
    }

    function onLayout(dc as Dc) as Void {
        width = dc.getWidth();
        fontHeight = dc.getFontHeight(Graphics.FONT_NUMBER_MEDIUM);
        height = dc.getHeight();

        getLocationCoordinates();

        var isFullWidth = width > locationCoordinates[0];
        smallFont = isFullWidth ? preferredSmallFont : true;

        if (smallFont) {
            zoneLabelOffsetX = dc.getTextWidthInPixels("Z1", fontDefinitions[2]) * 0.5;
        } else {
            zoneLabelOffsetX = dc.getTextWidthInPixels("Z1", fontDefinitions[1]) * 0.5;
        }
    }

    function getLocationCoordinates() as Void {
        var layoutConfig = HeartTooLayout.resolve(width, height, fontHeight);
        locationCoordinates = layoutConfig[:coordinates] as Array<Numeric>;
        fontDefinitions = layoutConfig[:fontDefinitions] as Array<FontDefinition>;

        var labelAdjustmentOffset = 10;
        var zoneBarMargin = locationCoordinates[HeartTooConstants.INDEX_ZONE_MARGIN];

        locationCoordinates[HeartTooConstants.INDEX_TITLE_Y] -= (zoneBarMargin + (drawLabels ? 0 : labelAdjustmentOffset));
        locationCoordinates[HeartTooConstants.INDEX_PRIMARY_POWER_Y] -= (zoneBarMargin + (drawLabels ? 0 : labelAdjustmentOffset));
        locationCoordinates[HeartTooConstants.INDEX_SECONDARY_POWER_Y] -= (zoneBarMargin + (drawLabels ? 0 : labelAdjustmentOffset));
        locationCoordinates[HeartTooConstants.INDEX_PRIMARY_METRIC_Y] -= (drawLabels ? 0 : labelAdjustmentOffset);
        locationCoordinates[HeartTooConstants.INDEX_RESERVED_Y] -= (zoneBarMargin + (drawLabels ? 0 : labelAdjustmentOffset));
        locationCoordinates[HeartTooConstants.INDEX_SECONDARY_METRIC_Y] -= (drawLabels ? 0 : labelAdjustmentOffset);

        if (width > 150) {
            locationCoordinates[HeartTooConstants.INDEX_PRIMARY_POWER_X] += 20;
            locationCoordinates[HeartTooConstants.INDEX_PRIMARY_METRIC_X] += 20;
        }
    }

    function compute(info as Activity.Info) as Void {
        if (info has :timerState && info.timerState == 0) {
            arrHeart = null;
            heartArray = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
            normalizeOn = false;
        }

        if (info has :currentHeartRate && info.currentHeartRate != null) {
            currentHeartRate = info.currentHeartRate;
        } else {
            currentHeartRate = 0;
            return;
        }

        computeHeartRates(info as Activity.Info, currentHeartRate);

        if (nSecondHeartRate > 0) {
            computeHeartZone(nSecondHeartRate);
        } else {
            currentHeartZone = 0;
            heartZoneDecimal = 0.0f;
        }

        if (showHeartZoneHistory && info has :timerState && info.timerState != 0) {
            if (currentHeartZone >= 1 && currentHeartZone <= 5 && currentHeartRate > 0) {
                var zoneCount = heartArray[currentHeartZone];
                zoneCount++;
                heartArray[currentHeartZone] = zoneCount;

                if (!normalizeOn && heartArray[currentHeartZone] > locationCoordinates[HeartTooConstants.INDEX_NORMALIZED_GRID_HEIGHT]) {
                    normalizeOn = true;
                }
            }
        }
    }

    function computeHeartRates(info as Activity.Info, currentHeartRateValue as Numeric) as Void {
        if (arrHeart == null) {
            arrHeart = [currentHeartRateValue];
        } else {
            if (arrHeart.size() < 30) {
                arrHeart.add(currentHeartRateValue);
            } else {
                arrHeart = HeartTooMath.pushWindow(arrHeart, currentHeartRateValue);
            }
        }

        var slicedHeartArray = null;
        var arraySize = arrHeart.size();

        switch (nSecondInterval) {
            case 1:
                nSecondHeartRate = currentHeartRateValue.toFloat();
                break;
            case 10:
                if (arraySize <= 10) {
                    nSecondHeartRate = HeartTooMath.mean(arrHeart);
                } else {
                    slicedHeartArray = arrHeart.slice(-10, null);
                    nSecondHeartRate = HeartTooMath.mean(slicedHeartArray);
                }
                break;
            case 30:
                nSecondHeartRate = HeartTooMath.mean(arrHeart);
                break;
            default:
                if (arraySize <= 3) {
                    nSecondHeartRate = HeartTooMath.mean(arrHeart);
                } else {
                    slicedHeartArray = arrHeart.slice(-3, null);
                    nSecondHeartRate = HeartTooMath.mean(slicedHeartArray);
                }
                break;
        }

        if (info has :averageHeartRate && info.averageHeartRate != null) {
            averageHeartRate = info.averageHeartRate;
        } else {
            averageHeartRate = 0;
        }

        if (info has :maxHeartRate && info.maxHeartRate != null) {
            maxHeartRate = info.maxHeartRate;
        } else {
            maxHeartRate = 0;
        }
    }

    function clearCanvas(dc as Dc) as Void {
        var backgroundColor = getBackgroundColor();
        var textColor = backgroundColor == Graphics.COLOR_BLACK ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;

        dc.setColor(textColor, backgroundColor);
        dc.clear();
    }

    function onUpdate(dc as Dc) as Void {
        clearCanvas(dc);
        var colors = {
            :background => -1,
            :color => null,
            :heart_color => null
        };

        var backgroundColor = getBackgroundColor();
        var defaultColor = backgroundColor == Graphics.COLOR_BLACK ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;

        colors[:heart_color] = defaultColor;
        colors[:color] = defaultColor;

        dc.setColor(colors[:color], colors[:background]);
        dc.clear();

        drawHeartZones(dc, colors);
        drawHeartData(dc, colors);

        if (dc.getWidth() > locationCoordinates[0]) {
            drawHeartSymbol(dc, 0, 8, Graphics.COLOR_RED);
        }
    }

    function computeHeartZone(heartRate as Number) as Void {
        var zoneOutput = { :value => 0 } as Dictionary;
        var decimalOutput = { :value => 0.0 } as Dictionary;

        heartZoneThreshold = HeartTooZones.getHeartRateThresholds();
        HeartTooZones.calculateZone(heartRate, heartZoneThreshold, zoneOutput, decimalOutput);

        currentHeartZone = zoneOutput[:value] as Numeric;
        heartZoneDecimal = decimalOutput[:value] as Numeric;
    }

    function drawHeartZones(dc as Dc, colors as Dictionary) {
        width = dc.getWidth();
        var backgroundColor = getBackgroundColor();
        var maxHeight = heartZoneBarHeight + heartZoneIndexHeight;

        var zoneWidth = Math.round((width - locationCoordinates[14] * 2.0) / 5.0);
        var bottomY = dc.getHeight();

        if (showHeartZoneBar) {
            dc.setColor(heartZoneColor[1], -1);
            dc.fillRectangle(locationCoordinates[14], bottomY - maxHeight - (currentHeartZone == 1 ? heartZoneIndexHeight : 0), zoneWidth - 1, maxHeight + (currentHeartZone == 1 ? heartZoneIndexHeight : 0));

            dc.setColor(heartZoneColor[2], -1);
            dc.fillRectangle(locationCoordinates[14] + zoneWidth, bottomY - maxHeight - (currentHeartZone == 2 ? heartZoneIndexHeight : 0), zoneWidth - 1, maxHeight + (currentHeartZone == 2 ? heartZoneIndexHeight : 0));

            dc.setColor(heartZoneColor[3], -1);
            dc.fillRectangle(locationCoordinates[14] + zoneWidth * 2.0, bottomY - maxHeight - (currentHeartZone == 3 ? heartZoneIndexHeight : 0), zoneWidth - 1, maxHeight + (currentHeartZone == 3 ? heartZoneIndexHeight : 0));

            dc.setColor(heartZoneColor[4], -1);
            dc.fillRectangle(locationCoordinates[14] + zoneWidth * 3.0, bottomY - maxHeight - (currentHeartZone == 4 ? heartZoneIndexHeight : 0), zoneWidth - 1, maxHeight + (currentHeartZone == 4 ? heartZoneIndexHeight : 0));

            dc.setColor(heartZoneColor[5], -1);
            dc.fillRectangle(locationCoordinates[14] + zoneWidth * 4.0, bottomY - maxHeight - (currentHeartZone == 5 ? heartZoneIndexHeight : 0), zoneWidth - 1, maxHeight + (currentHeartZone == 5 ? heartZoneIndexHeight : 0));
        }

        var verticalCenter = bottomY - maxHeight;

        if (showHeartZoneHistory) {
            var maximumValue = 0.0f;
            for (var zoneIndex = 1; zoneIndex < 6; zoneIndex++) {
                if (heartArray[zoneIndex] > maximumValue) {
                    maximumValue = heartArray[zoneIndex];
                }
            }

            for (var historyZoneIndex = 1; historyZoneIndex < 6; historyZoneIndex++) {
                var normalizedValue = heartArray[historyZoneIndex];
                if (normalizeOn && maximumValue > 0) {
                    normalizedValue = heartArray[historyZoneIndex] / maximumValue * locationCoordinates[HeartTooConstants.INDEX_NORMALIZED_GRID_HEIGHT];
                }

                dc.setColor(heartZoneColor[historyZoneIndex], -1);
                var xPosition = locationCoordinates[14] + zoneWidth * (historyZoneIndex - 1);
                for (var gridLineIndex = 0; gridLineIndex < normalizedValue; gridLineIndex++) {
                    var yPosition = verticalCenter - (gridLineIndex + 1) * 4;
                    dc.drawLine(xPosition, yPosition, xPosition + zoneWidth - 1, yPosition);
                }
            }
        }

        if (showHeartZoneBar) {
            var centerX = locationCoordinates[14];
            var arrowColor = backgroundColor == Graphics.COLOR_BLACK ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;
            var arrowHeight = maxHeight;

            if (currentHeartZone == 0) {
                centerX = locationCoordinates[14];
            } else if (currentHeartZone == 5 && heartZoneDecimal == 1) {
                centerX = locationCoordinates[14] + zoneWidth * 5;
            } else {
                centerX = locationCoordinates[14] + zoneWidth * (currentHeartZone - 1) + zoneWidth * heartZoneDecimal;
            }

            dc.setColor(backgroundColor, -1);
            dc.fillPolygon([[centerX - 2, verticalCenter + arrowHeight], [centerX - 2, verticalCenter - 10], [centerX + 2, verticalCenter - 10], [centerX + 2, verticalCenter + arrowHeight]]);
            dc.setColor(arrowColor, -1);
            dc.fillPolygon([[centerX - 1, verticalCenter + arrowHeight], [centerX - 1, verticalCenter - 9], [centerX + 1, verticalCenter - 9], [centerX + 1, verticalCenter + arrowHeight]]);
        }
    }

    function drawHeartData(dc as Dc, colors as Dictionary) {
        width = dc.getWidth();
        var heightOffset = height * 0.1;
        var zoneColor = HeartTooZones.getZoneColor(currentHeartZone, heartZoneColor);

        var displayMode = HeartTooRenderer.getDisplayMode(width, height, locationCoordinates[0], smallFont, averageMode);

        var heartValues = { :data => null } as Dictionary;
        var zoneValues = { :data => null } as Dictionary;
        HeartTooRenderer.getDisplayValues(displayMode, locationCoordinates, fontDefinitions, width, fontHeight, heartValues, zoneValues);

        var heartDisplayValues = heartValues[:data] as Array;
        var zoneDisplayValues = zoneValues[:data] as Array;

        if (nSecondHeartRate != null && nSecondHeartRate >= 0) {
            dc.setColor(colors[:heart_color], -1);
            dc.drawText((heartDisplayValues[0] as Numeric), (heartDisplayValues[1] as Numeric), heartDisplayValues[2], nSecondHeartRate.format("%d"), Graphics.TEXT_JUSTIFY_RIGHT);
        }

        dc.setColor(zoneColor, colors[:background]);
        if (drawCurrentZone) {
            dc.drawText((zoneDisplayValues[0] as Numeric), (zoneDisplayValues[1] as Numeric) + locationCoordinates[14], zoneDisplayValues[2], "Z" + currentHeartZone.format("%d"), zoneDisplayValues[3]);
        }

        var displayedHeartValue = getDisplayedHeartValue(averageMode);

        var shortTermLabel = HeartTooRenderer.getIntervalLabel(nSecondInterval, modeShortTermHeart);
        var averageLabel = HeartTooRenderer.getAverageModeLabel(averageMode, modeAverageHeart);
        var displayTitle = HeartTooRenderer.buildDisplayTitle(width, displayMode, shortTermLabel, averageLabel);

        dc.setColor(colors[:color], colors[:background]);
        drawHeartDataByMode(dc, displayMode, displayedHeartValue, displayTitle, heightOffset, averageLabel);
    }

    private function getDisplayedHeartValue(mode as Numeric) as String {
        switch (mode) {
            case 1:
                return maxHeartRate.format("%d");
            default:
                return averageHeartRate.format("%d");
        }
    }

    private function drawHeartDataByMode(dc as Dc, mode as Numeric, value as String, titleValue as String, heightOffset as Numeric, avgLabel as String) as Void {
        switch (mode) {
            case 0:
                drawModeFullWidth(dc, value, heightOffset, titleValue, avgLabel);
                break;
            case 2:
                drawModeHalfWidthBig(dc, value, titleValue);
                break;
            case 4:
                drawModeHalfWidthSmall(dc, value, titleValue);
                break;
            default:
                drawModeFullWidth(dc, value, heightOffset, titleValue, avgLabel);
                break;
        }
    }

    private function drawModeFullWidth(dc as Dc, value as String, heightOffset as Numeric, titleValue as String, avgLabel as String) as Void {
        if (drawLabels) {
            dc.drawText(width * 0.5, locationCoordinates[1] + locationCoordinates[14], fontDefinitions[3], titleValue, Graphics.TEXT_JUSTIFY_CENTER);
        }

        if (height > 100) {
            dc.drawText(locationCoordinates[6], locationCoordinates[7] + heightOffset, fontDefinitions[3], metric, Graphics.TEXT_JUSTIFY_LEFT);
            var numberFontTall = smallFont ? Graphics.FONT_NUMBER_MILD : Graphics.FONT_NUMBER_MEDIUM;
            dc.drawText(locationCoordinates[4], locationCoordinates[5] + heightOffset, numberFontTall, value, Graphics.TEXT_JUSTIFY_RIGHT);
            if (showAverageHeartRate) {
                dc.drawText(locationCoordinates[10], locationCoordinates[7] + heightOffset, fontDefinitions[3], metric, Graphics.TEXT_JUSTIFY_LEFT);
                dc.drawText(locationCoordinates[10], locationCoordinates[5] + heightOffset, fontDefinitions[3], avgLabel, Graphics.TEXT_JUSTIFY_LEFT);
            }
        } else {
            dc.drawText(locationCoordinates[6], locationCoordinates[7], fontDefinitions[3], metric, Graphics.TEXT_JUSTIFY_LEFT);
            var numberFontCompact = smallFont ? Graphics.FONT_NUMBER_MILD : Graphics.FONT_NUMBER_MEDIUM;
            dc.drawText(locationCoordinates[4], locationCoordinates[5], numberFontCompact, value, Graphics.TEXT_JUSTIFY_RIGHT);
            if (showAverageHeartRate) {
                dc.drawText(locationCoordinates[10], locationCoordinates[7], fontDefinitions[3], metric, Graphics.TEXT_JUSTIFY_LEFT);
                dc.drawText(locationCoordinates[10], locationCoordinates[11], fontDefinitions[3], avgLabel, Graphics.TEXT_JUSTIFY_LEFT);
            }
        }
    }

    private function drawModeHalfWidthBig(dc as Dc, value as String, titleValue as String) as Void {
        if (drawLabels) {
            dc.drawText(width * 0.5 + zoneLabelOffsetX, locationCoordinates[1] + locationCoordinates[14], fontDefinitions[3], titleValue, Graphics.TEXT_JUSTIFY_CENTER);
        }
        dc.drawText(locationCoordinates[8], locationCoordinates[9], fontDefinitions[1], value, Graphics.TEXT_JUSTIFY_RIGHT);
        if (showAverageHeartRate) {
            dc.drawText(locationCoordinates[12], locationCoordinates[11], fontDefinitions[3], metric, Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    private function drawModeHalfWidthSmall(dc as Dc, value as String, titleValue as String) as Void {
        if (drawLabels) {
            dc.drawText(width * 0.5 + zoneLabelOffsetX, locationCoordinates[1] + locationCoordinates[14], fontDefinitions[3], titleValue, Graphics.TEXT_JUSTIFY_CENTER);
        }
        dc.drawText(locationCoordinates[6], locationCoordinates[7], fontDefinitions[2], value, Graphics.TEXT_JUSTIFY_RIGHT);
        if (showAverageHeartRate) {
            dc.drawText(locationCoordinates[10], locationCoordinates[11], fontDefinitions[3], metric, Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    function readModeShortTermHeart() {
        modeShortTermHeart[0] = loadResource(Rez.Strings.modeNone);
        modeShortTermHeart[1] = loadResource(Rez.Strings.mode3s);
        modeShortTermHeart[2] = loadResource(Rez.Strings.mode10s);
        modeShortTermHeart[3] = loadResource(Rez.Strings.mode30s);
    }

    function readModeAverageHeart() {
        modeAverageHeart[0] = loadResource(Rez.Strings.modeAvg);
        modeAverageHeart[1] = loadResource(Rez.Strings.modeMax);
    }

    function drawHeartSymbol(dc, xOffset, yOffset, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        xOffset = xOffset + 10;
        yOffset = yOffset + 13;

        dc.fillCircle(xOffset - 3, yOffset, 4);
        dc.fillCircle(xOffset + 3, yOffset, 4);
        dc.fillPolygon([[xOffset - 7, yOffset + 2], [xOffset, yOffset + 8], [xOffset + 7, yOffset + 2]]);
    }
}
