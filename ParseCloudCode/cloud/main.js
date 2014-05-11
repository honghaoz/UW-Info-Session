
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

Parse.Cloud.define("countInstallation", function(request, response) {
	var query = new Parse.Query("Installation");
	query.find({
		success: function(results) {
			var sum = 0;
			for (var i = 0; i < results.length; i++) {
				sum += 1
			}
			response.success(sum);
		},
		error: function() {
			response.error("failed");
		}
	});
});