import Vapor
import Fluent
import Foundation
import Graphene

final class Example: Model {
    var id: Node?

    var input: String
    var output: String {
        return boardString(newBoard)
    }
    var history = [String]()
    var snapshot = [Int]()
    var numBlack: Int {
        return newBoard.getNumBlack()
    }
    var numWhite: Int {
        return newBoard.getNumWhite()
    }
    var strong: Bool
    
    let board: Board = SimpleBitBoard()
    var think: Think {
        if strong {
            return SearchEvalThink(searcher: NegaAlphaSearch(), zones:ZonesFactory.createZoneTypical8(99, bVal: 1.6, cVal: -5, dVal: 7.5, eVal: 6.1, fVal: 4.3, gVal: 4.8, hVal: 5), pnsLessThan: 10, searchDepth: 6, wPossibleMoves: [20.0, 15, 3.2, 1.1], wEdge: [1.0, 1.0], wFixedPieces: [2.0, 200.0], wOpenness: [2.5, 3.5], wBoardEvaluation: [2.5, 5.0])
        } else {
            return RandomWithWeightsThink(zones: ZonesFactory.createZoneTypical4(99, bVal: 1, cVal: 8, dVal: 16))
        }
    }
    let info = NullInfo()

    lazy var newBoard: Board = {
//        for (i, h) in self.history.enumerated() {
//            let color: Pieces = i % 2 == 0 ? .black : .white
//            let _ = process(board: board, sfen: h, color: color)
//        }
        for (i, s) in self.snapshot.enumerated() {
            let y = i / self.board.height()
            let x = i % self.board.height()
            let color: Pieces
            switch s {
            case 1:
                color = .black
            case 2:
                color = .white
            case 3:
                color = .empty
            case 4:
                color = .guide
            default:
                color = .none
            }
            self.board.set(color, x: x, y: y)
        }

        guard !self.input.isEmpty else { return self.guide(self.board) }

        let board1 = self.process(board: self.board.clone(), sfen: self.input, color: .black)
        self.history.append(self.diff(board1: self.board, board2: board1))
        let board2 = self.process(board: board1.clone(), sfen: "go", color: .white)
        self.history.append(self.diff(board1: board1, board2: board2))

        return self.guide(board2)
    }()

    func guide(_ board: Board) -> Board {
        let _ = board.updateGuides(.black)
        return board
    }

    func process(board: Board, sfen: String, color: Pieces) -> Board {
        switch processSfen(playerName: "", sfen: sfen, think: think, board: board, color: color, info: info) {
        case .Game(_):
            break
        case let .Moved(newBoard):
            return newBoard
        case .Quit:
            break
        }
        return board
    }

    func boardString(_ board: Board) -> String {
        let rows = board
            .toString()
            .replacingOccurrences(of: " ", with: "", options: .regularExpression, range: nil)
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
            .enumerated()
            .map { (i, row) in "\(i + 1)\(row)" }
        return ([" abcdefgh"] + rows).joined(separator: "\n")
    }

    func boardSnapshot(_ board: Board) -> [Int] {
        return (0..<board.height()).map { y in
            return (0..<board.width()).map { x in
                return board.get(x, y: y).toInt()
            }
        }.flatMap{ $0 }
    }

    func diff(board1: Board, board2: Board) -> String {
        for y in 0..<board.height() {
            for x in 0..<board.width() {
                let p1 = board1.get(x, y: y)
                let p2 = board2.get(x, y: y)
                if p1 == .empty && p2 != .empty {
                    return strFromMove(move: .Move(x, y))
                }
            }
        }
        return "PS"
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        input = try node.extract("input")
        history = try node.extract("history")
        snapshot = try node.extract("snapshot")
        strong = try node.extract("strong")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "input": input,
            "output": output,
            "history": Node.array(history.map { .string($0) }),
            "snapshot": Node.array(boardSnapshot(newBoard).map { .number(Node.Number($0)) }),
            "numBlack" : numBlack,
            "numWhite" : numWhite,
            "strong" : strong,
        ])
    }
}

extension Example: Preparation {
    static func prepare(_ database: Database) throws {
        //
    }

    static func revert(_ database: Database) throws {
        //
    }
}
