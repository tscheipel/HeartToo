import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class HeartTooApp extends Application.AppBase {

	var dataField;
	
    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    //! Return the initial view of your application here
    function getInitialView() {
	    dataField = new HeartTooView();
        return [ dataField ];
    }

	function onSettingsChanged() {
		dataField.initProperties();
		dataField.getLocationCoordinates();
	}
}

function getApp() as HeartTooApp {
    return Application.getApp() as HeartTooApp;
}
