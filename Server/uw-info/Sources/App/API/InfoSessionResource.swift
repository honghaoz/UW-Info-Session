//
//  InfoSessionResource.swift
//  uw-info
//
//  Created by Honghao Zhang on 2017-05-07.
//
//

import Foundation
import Vapor
import HTTP

//final class InfoSessionResource: ResourceRepresentable {
//	
//	/**
//	GET			/user		index
//	POST		/user		create
//	GET			/user/:id	show
//	PUT			/user/:id	replace
//	PATCH		/user/:id	update
//	DELETE		/user/:id	delete
//	DELETE		/user		clear
//	*/
//	func makeResource() -> Resource<Post> {
//		return Resource(
//			index: index,
//			store: create,
//			show: show,
//			replace: replace,
//			modify: update,
//			destroy: delete,
//			clear: clear
//		)
//	}
//}
//
//// MARK: - Resource
//extension InfoSessionResource {
//	func index(request: Request) throws -> ResponseRepresentable {
//		return try User.all().makeNode().converted(to: JSON.self)
//	}
//	
//	func create(request: Request) throws -> ResponseRepresentable {
//	}
//	
//	func show(request: Request, user: User) throws -> ResponseRepresentable {
//		return user
//	}
//	
//	func replace(request: Request, user: User) throws -> ResponseRepresentable {
//		try user.delete()
//		return try create(request: request)
//	}
//	
//	func update(request: Request, user: User) throws -> ResponseRepresentable {
//		var user = user
//		user.update(with: request)
//		try user.save()
//		return user
//	}
//	
//	func delete(request: Request, user: User) throws -> ResponseRepresentable {
//		try user.delete()
//		return JSON([:])
//	}
//	
//	func clear(request: Request) throws -> ResponseRepresentable {
//		try User.query().delete()
//		return JSON([])
//	}
//}
