
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

Parse.Cloud.define("count", function(request, response) {
	var query = new Parse.Query("Device");

	query.find({
		success: function(results) {
			response.success(results.length);
		},
		error: function() {
			response.error("failed");
		}
	});
});

Parse.Cloud.define("PushNotification", function(request, response) {
	var pushType = request.params.type;
	if (pushType === 'NewDevice') {
		var newDeviceCount = request.params.newDeviceCount;
		var addedNumber = request.params.addedNumber;
		var alertMessage = addedNumber + " ";
		if (addedNumber == 1) {
			alertMessage += "device "
		} else {
			alertMessage += "devices "
		}
		alertMessage += "added!";
		var query = new Parse.Query(Parse.Installation);
		query.equalTo('channels', 'admin');
		Parse.Push.send({
			where : query,
			data : {
				alert: alertMessage,
				badge: 'Increment',
				sound: 'alarm.caf'
			}
		}, {
			success: function() {
				console.log("Push succeed!");
				var query = new Parse.Query("Count");
				query.find({
					success : function(results) {
						var theCount = results[0];
						theCount.set('DeviceCount', newDeviceCount);
						console.log('Set device count: ' + newDeviceCount);
						theCount.save(null, {
							success: function() {

							},
							error: function() {

							}
						});
						response.success("success");
					},
					error : function() {
						response.error('failed');
					}
				});
			},
			error: function() {
				console.log("Push failed!");
				response.error('failed');
			}
		});
	};
});

function Count(className, callback) {
	console.log("Function: Count called");
	var query = new Parse.Query(className);
	var result = 0;
	query.count({
		success: function(count) {
			result = count;
			console.log("Count: " + result);
			callback(result);
		},
		error: function(error) {
			console.log("Count " + className + " Failed");
			result = -1;
			callback(result);
		}
	});
}

function CheckDevice(request, response) {
	console.log("Function: CheckDevice called");
	var query = new Parse.Query("Count");
    query.find({
    	success : function(results) {
    		var theCount = results[0];
    		var oldDeviceCount = theCount.get("DeviceCount");
    		console.log("Old: " + oldDeviceCount);
    		
    		var newDeviceCount = 0;
    		Count("Device", function(countResult) {
    			console.log("Callback function called");
    			newDeviceCount = countResult;
    			console.log("New: " + newDeviceCount);
    			var addedDevices = newDeviceCount - oldDeviceCount;
    			if (addedDevices > 0) {
    				Parse.Cloud.run('PushNotification', {type: 'NewDevice', addedNumber: addedDevices, newDeviceCount: newDeviceCount}, {
    					success: function(pushResult) {
    						response.success(addedDevices + " devices are added" + " Push succeed");
    					},
    					error: function(error) {
    						response.error(addedDevices + " devices are added" + " Push failed");
    					}
    				});
    			} else if (addedDevices === 0) {
    				response.success(addedDevices + " devices are added, no push");
    			} else {
    				response.error("Wrong addedDevices number (<0)");
    			}
    		});
    	},
    	error : function() {
    		response.error("Check devices failed");
    	}
    });
}

// Bacground jobs
Parse.Cloud.job("CheckDevices", function (request, status) {
    CheckDevice(request, status);
});
 
Parse.Cloud.define("CheckDevices", function (request, response) {
    CheckDevice(request, response);
});

Parse.Cloud.job("TestBackground", function (request, status) {
    status.success("Test succeed");
});
