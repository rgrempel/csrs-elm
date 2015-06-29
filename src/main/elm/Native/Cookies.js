Elm.Native.Cookies = {};
Elm.Native.Cookies.make = function (localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Cookies = localRuntime.Native.Cookies || {};
	
    if (!localRuntime.Native.Cookies.values) {
        var Task = Elm.Native.Task.make(localRuntime);

        localRuntime.Native.Cookies.values = {
            getCookieString: Task.asyncFunction(function (callback) {
                return callback(Task.succeed(document.cookie));
            })
        };
    }
    
    return localRuntime.Native.Cookies.values;
};
