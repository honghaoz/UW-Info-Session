import Vapor

let drop = Droplet()

drop.console.info(("Environment: \(drop.environment)"))

drop.get { req in
	return "UWaterloo Info Session API!"
}

//drop.resource("api/infosessions", PostController())

drop.run()
