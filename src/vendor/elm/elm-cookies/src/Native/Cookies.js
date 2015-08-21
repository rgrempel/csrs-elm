Elm.Native.Cookies = {};
Elm.Native.Cookies.make = function (localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Cookies = localRuntime.Native.Cookies || {};
	
    if (!localRuntime.Native.Cookies.values) {
        var Task = Elm.Native.Task.make(localRuntime);
    	var Utils = Elm.Native.Utils.make(localRuntime);

        var getString = Task.asyncFunction(function (callback) {
            return callback(Task.succeed(document.cookie));
        });

        var setString = function (cookie) {
            return Task.asyncFunction(function (callback) {
                document.cookie = cookie;
                return callback(Task.succeed(Utils.Tuple0));
            });
        };

        var dateToUTCString = function (date) {
            return date.toUTCString();
        };

        localRuntime.Native.Cookies.values = {
            getString: getString,
            setString: setString,
            dateToUTCString: dateToUTCString
        };
    }
    
    return localRuntime.Native.Cookies.values;
};
