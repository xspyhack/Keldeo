import Foundation

public protocol Formatter {

    func format(message: Message) -> String
}
