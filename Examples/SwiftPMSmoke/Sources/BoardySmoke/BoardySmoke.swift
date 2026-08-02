import Boardy

public func makeBoardySmokeMotherboard() -> (BoardID, Motherboard) {
    let identifier: BoardID = "swiftpm-smoke"
    return (identifier, Motherboard(identifier: identifier))
}
