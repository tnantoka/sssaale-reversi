import Vapor

public let title = "SSSaaLE (Graphene)"

public func load(_ drop: Droplet) {
    // drop.get { _ in return "hello" }
    drop.get { req in
        return try drop.view.make("welcome", [
            "title": title
        ])
    }
    drop.resource("example", ExampleController())
}
