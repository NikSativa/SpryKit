import Foundation
import SpryKit
import XCTest

final class RecursiveGraphXCTests: XCTestCase {
    func test_a_self_referencing_pair_is_compared_without_recursing_forever() {
        let lhs = GraphNode("same")
        lhs.peer = lhs
        let rhs = GraphNode("same")
        rhs.peer = rhs

        XCTAssertTrue(isAnyEqual(lhs, rhs))

        let other = GraphNode("different")
        other.peer = other
        XCTAssertFalse(isAnyEqual(lhs, other))
    }

    func test_a_mutual_cycle_is_compared_without_recursing_forever() {
        XCTAssertTrue(isAnyEqual(GraphNode.mutualCycle(head: "a", tail: "b"),
                                 GraphNode.mutualCycle(head: "a", tail: "b")))
        XCTAssertFalse(isAnyEqual(GraphNode.mutualCycle(head: "a", tail: "b"),
                                  GraphNode.mutualCycle(head: "a", tail: "z")))
    }

    func test_a_graph_deeper_than_the_limit_is_reported_instead_of_overflowing() {
        XCTAssertTrue(isAnyEqual(GraphChain.make(length: 20), GraphChain.make(length: 20)))
        XCTAssertFalse(isAnyEqual(GraphChain.make(length: 20), GraphChain.make(length: 21)))

        XCTAssertThrowsAssertion {
            _ = isAnyEqual(GraphChain.make(length: 400), GraphChain.make(length: 400))
        }
    }

    func test_a_cycle_inside_a_collection_is_handled() {
        let lhs = GraphNode("x")
        lhs.peer = lhs
        let rhs = GraphNode("x")
        rhs.peer = rhs

        XCTAssertTrue(isAnyEqual([lhs], [rhs]))
        XCTAssertTrue(isAnyEqual(["key": lhs], ["key": rhs]))
    }

    func test_a_cycle_is_matched_as_a_stub_argument() {
        let fake = GraphFake()
        let expected = GraphNode("node")
        expected.peer = expected

        fake.stub(.takeWithNode).with(expected).andReturn()

        let actual = GraphNode("node")
        actual.peer = actual
        fake.take(node: actual)

        XCTAssertHaveReceived(fake, .takeWithNode, with: expected)
    }

    func test_diffMirror_survives_a_cycle() {
        let lhs = GraphNode("a")
        lhs.peer = lhs
        let rhs = GraphNode("b")
        rhs.peer = rhs

        let subject = Spry.diffMirror(lhs, rhs).joined()
        XCTAssertTrue(subject.contains("Received: b"))
        XCTAssertTrue(subject.contains("Expected: a"))

        let same = GraphNode("a")
        same.peer = same
        XCTAssertTrue(Spry.diffMirror(lhs, same).isEmpty)
    }

    func test_diffMirror_stops_at_the_depth_limit_instead_of_overflowing() {
        let subject = Spry.diffMirror(GraphChain.make(length: 400), GraphChain.make(length: 401)).joined()

        XCTAssertTrue(subject.contains("Nested deeper than"))
    }
}

private final class GraphFake: Spryable {
    enum ClassFunction: String, StringRepresentable {
        case _unknown_
    }

    enum Function: String, StringRepresentable {
        case takeWithNode = "take(node:)"
    }

    func take(node: GraphNode) {
        return spryify(arguments: node)
    }
}

private final class GraphNode {
    let name: String
    var peer: GraphNode?

    init(_ name: String) {
        self.name = name
    }

    static func mutualCycle(head: String, tail: String) -> GraphNode {
        let first = GraphNode(head)
        let second = GraphNode(tail)
        first.peer = second
        second.peer = first
        return first
    }
}

private final class GraphChain {
    var next: GraphChain?
    var value: Int = 0

    static func make(length: Int) -> GraphChain {
        let head = GraphChain()
        var current = head
        for index in 0..<length {
            let next = GraphChain()
            next.value = index
            current.next = next
            current = next
        }
        return head
    }
}
