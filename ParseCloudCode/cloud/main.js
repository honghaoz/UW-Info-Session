
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
	var type = request.params.type;
	var newCount = request.params.newCount;
	var addedNumber = request.params.addedNumber;
	var alertMessage = addedNumber + " " + type + " added!";
	
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
					theCount.set(type + 'Count', newCount);
					// console.log('Set device count: ' + newDeviceCount);
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
});

function Count(className, callback) {
	console.log("Function: Count called");
	var promise = new Parse.Promise();
	var query;
	if (className === "Installation") {
		query = new Parse.Query(Parse.Installation);
	} else {
		query = new Parse.Query(className);
	};
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

function executePush(type, added, newCount, callback) {
	if (added > 0) {
		Parse.Cloud.run('PushNotification', 
			{
				type: type, 
				addedNumber: added, 
				newCount: newCount
			}, {
			success: function(pushResult) {
				// response.success(type + ": " + added + " objects are added" + " Push succeed");
				callback(true, true, 1);
			},
			error: function(error) {
				// response.error(type + ": " + added + " objects are added" + " Push failed");
				callback(true, false, 0);
			}
		});
	} else if (added === 0) {
		// response.success(type + ": " + added + " objects are added, no push");
		callback(true, true, 0);
	} else {
		// response.error(type + ": " + "Wrong added number (<0)");
		// Update count class
		var query = new Parse.Query("Count");
			query.find({
				success : function(results) {
					var theCount = results[0];
					theCount.set(type + 'Count', newCount);
					// console.log('Set device count: ' + newDeviceCount);
					theCount.save(null, {
						success: function() {
							callback(false, false, 0);
						},
						error: function() {
							// callback(false, false, 0);
						}
					});
					// response.success("success");
				},
				error : function() {
					// response.error('failed');
				}
			});
	}
}

function Check(type, request, response) {
	console.log("Function: CheckDevice called");
	var query = new Parse.Query("Count");
    query.find({
    	success : function(results) {
    		var theCount = results[0];
    		// var oldCountDic = {};
    		// var oldDeviceCount = theCount.get("DeviceCount");
    		// console.log("oldDeviceCount: " + oldDeviceCount);
    		// oldCountDic["Device"] = oldDeviceCount;
    		// var oldInstallationCount = theCount.get("InstallationCount");
    		// console.log("oldInstallationCount: " + oldInstallationCount);
    		// oldCountDic["Installation"] = oldInstallationCount;
    		// var oldErrorCount = theCount.get("ErrorCount");
    		// console.log("oldErrorCount: " + oldErrorCount);
    		// oldCountDic["Error"] = oldErrorCount;
    		// var oldFeedbackCount = theCount.get("FeedbackCount");
    		// console.log("oldFeedbackCount: " + oldFeedbackCount);
    		// oldCountDic["Feedback"] = oldFeedbackCount;

    		// var newCount = 0;
    		// var types = ["Device", "Feedback", "Error"];
    		var oldCount = theCount.get(type + "Count");
    		var newCount = 0;
			Count(type, function(countResult) {
				newCount = countResult;
				console.log("new" + type + "Count: " + newCount);
				var added = newCount - oldCount;
				executePush(type, added, newCount, function(addResult, pushResult, pushCount) {
					if (addResult === true) {
						if (pushResult === true) {
							response.success(type + ": " + added + " objects are added" + " Push succeed");
							// responseSuccessMessage += type + ": " + added + " objects are added" + " Push succeed\n";
						} else {
							response.error(type + ": " + added + " objects are added" + " Push failed");
							// responseSuccessMessage += type + ": " + added + " objects are added" + " Push faile\n";
						};
					} else {
						response.error(type + ": " + "Wrong added number (<0)");
						// responseSuccessMessage += type + ": " + "Wrong added number (<0)\n";
					};
				});
			});
    	},
    	error : function() {
    		response.error("Check devices failed");
    	}
    });
}

// Bacground jobs
Parse.Cloud.job("CheckDevices", function (request, status) {
    Check("Device", request, status);
});
 
// Parse.Cloud.define("CheckDevices", function (request, response) {
//     Check("Device", request, response);
// });

Parse.Cloud.job("CheckErrors", function (request, status) {
    Check("Error", request, status);
});

Parse.Cloud.job("CheckFeedbacks", function (request, status) {
    Check("Feedback", request, status);
});
 
// Parse.Cloud.define("CheckDevices", function (request, response) {
//     Check("Device", request, response);
// });

// Parse.Cloud.job("CheckDevices", function (request, status) {
//     Check("Device", request, status);
// });
 
// Parse.Cloud.define("CheckDevices", function (request, response) {
//     Check("Device", request, response);
// });

function Color(red, green, blue, alpha) {
	this.red = red;
	this.green = green;
	this.blue = blue;
	this.alpha = alpha;
    this.getDic = function() {
    	var dic = {};
    	dic["red"] = red;
    	dic["green"] = green;
    	dic["blue"] = blue;
    	dic["alpha"] = alpha;
        return dic;
    };
}

function getContrastYIQ(r, g, b, callback){
	console.log("r: " + r)
	console.log("g: " + g)
	console.log("b: " + b)
	var yiq = ((r * 255 * 299)+(g * 255 * 587)+(b * 255 * 114))/1000;
	if (yiq >= 128) {
		callback('black');
	} else {
		callback('white');
	} 
}



Parse.Cloud.define("getColorScheme", function(request, response) {
	var gold = new Color(Math.random(), Math.random(), Math.random(), 1);
	//var uwblack = new Color(0.13, 0.14, 0.17, 1); //new Color(Math.random(), Math.random(), Math.random(), 1);
	var statusBar = false;
	var black = new Color(0, 0, 0, 1);

	getContrastYIQ(gold.red, gold.green, gold.blue, function (color) {
		if (color === 'black') {
			var tab = black;
			var colorSchemeDic = {};
			colorSchemeDic["uwGoldColor"] = gold.getDic();
			colorSchemeDic["uwBlackColor"] = black.getDic();
			colorSchemeDic["uwTabColor"] = tab.getDic();
			colorSchemeDic["statusBarIsLight"] = statusBar;
			response.success(colorSchemeDic);
		} else {
			black = new Color(1, 1, 1, 1);
			statusBar = true;
			var tab = black;
			var colorSchemeDic = {};
			colorSchemeDic["uwGoldColor"] = gold.getDic();
			colorSchemeDic["uwBlackColor"] = black.getDic();
			colorSchemeDic["uwTabColor"] = tab.getDic();
			colorSchemeDic["statusBarIsLight"] = statusBar;
			response.success(colorSchemeDic);
		}
	});

	// if (getContrastYIQ(gold.red, gold.green, gold.blue) == 'white') {
	// 	black = new Color(1, 1, 1, 1);
	// 	var statusBar = true;
	// };

	// var tab = black;//black;//new Color(Math.random(), Math.random(), Math.random(), 1);
	// if (Math.random() > 0.5) {
	// 	statusBar = true;
	// } else {
	// 	statusBar = false;
	// }
	// var colorSchemeDic = {};
	// colorSchemeDic["uwGoldColor"] = gold.getDic();
	// colorSchemeDic["uwBlackColor"] = black.getDic();
	// colorSchemeDic["uwTabColor"] = tab.getDic();
	// colorSchemeDic["statusBarIsLight"] = statusBar;
	// response.success(colorSchemeDic);
});
