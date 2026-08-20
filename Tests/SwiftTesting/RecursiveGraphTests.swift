#if canImport(Testing)
import Foundation
import SpryKit
import Testing

@Suite("Recursive Graph Tests", .serialized)
struct RecursiveGraphTests {
    @Test("A self referencing pair is compared without recursing forever")
    func a_self_referencing_pair_is_compared_without_recursing_forever() {
        let lhs = GraphNode("same")
        lhs.peer = lhs
        let rhs = GraphNode("same")
        rhs.peer = rhs

        #expect(isAnyEqual(lhs, rhs))

        let other = GraphNode("different")
        other.peer = other
        #expect(!isAnyEqual(lhs, other))
    }

    @Test("A mutual cycle is compared without recursing forever")
    func a_mutual_cycle_is_compared_without_recursing_forever() {
        #expect(isAnyEqual(GraphNode.mutualCycle(head: "a", tail: "b"),
                           GraphNode.mutualCycle(head: "a", tail: "b")))
        #expect(!isAnyEqual(GraphNode.mutualCycle(head: "a", tail: "b"),
                            GraphNode.mutualCycle(head: "a", tail: "z")))
    }

    @Test("A graph deeper than the limit is reported instead of overflowing")
    func a_graph_deeper_than_the_limit_is_reported_instead_of_overflowing() {
        #expect(isAnyEqual(GraphChain.make(length: 20), GraphChain.make(length: 20)))
        #expect(!isAnyEqual(GraphChain.make(length: 20), GraphChain.make(length: 21)))

        expectThrowsAssertion {
            _ = isAnyEqual(GraphChain.make(length: 400), GraphChain.make(length: 400))
        }
    }

    @Test("A cycle inside a collection is handled")
    func a_cycle_inside_a_collection_is_handled() {
        let lhs = GraphNode("x")
        lhs.peer = lhs
        let rhs = GraphNode("x")
        rhs.peer = rhs

        #expect(isAnyEqual([lhs], [rhs]))
        #expect(isAnyEqual(["key": lhs], ["key": rhs]))
    }

    @Test("A cycle is matched as a stub argument")
    func a_cycle_is_matched_as_a_stub_argument() {
        let fake = GraphFake()
        let expected = GraphNode("node")
        expected.peer = expected

        fake.stub(.takeWithNode).with(expected).andReturn()

        let actual = GraphNode("node")
        actual.peer = actual
        fake.take(node: actual)

        #expect(fake.didCall(.takeWithNode, withArguments: [expected]).isSuccess)
    }

    @Test("diffMirror survives a cycle")
    func diffMirror_survives_a_cycle() {
        let lhs = GraphNode("a")
        lhs.peer = lhs
        let rhs = GraphNode("b")
        rhs.peer = rhs

        let subject = Spry.diffMirror(lhs, rhs).joined()
        #expect(subject.contains("Received: b"))
        #expect(subject.contains("Expected: a"))

        let same = GraphNode("a")
        same.peer = same
        #expect(Spry.diffMirror(lhs, same).isEmpty)
    }

    @Test("diffMirror stops at the depth limit instead of overflowing")
    func diffMirror_stops_at_the_depth_limit_instead_of_overflowing() {
        let subject = Spry.diffMirror(GraphChain.make(length: 400), GraphChain.make(length: 401)).joined()

        #expect(subject.contains("Nested deeper than"))
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
#endif // canImport(Testing)
