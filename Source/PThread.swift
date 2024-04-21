import Foundation

@preconcurrency
internal final class PThread: @unchecked Sendable {
    enum Kind {
        case normal
        case recursive
    }

    private var _lock: pthread_mutex_t = .init()

    init(kind: Kind) {
        var attr = pthread_mutexattr_t()

        guard pthread_mutexattr_init(&attr) == 0 else {
            preconditionFailure()
        }

        switch kind {
        case .normal:
            pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL)
        case .recursive:
            pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE)
        }

        guard pthread_mutex_init(&_lock, &attr) == 0 else {
            preconditionFailure()
        }

        pthread_mutexattr_destroy(&attr)
    }

    deinit {
        pthread_mutex_destroy(&_lock)
    }

    func lock() {
        pthread_mutex_lock(&_lock)
    }

    func tryLock() -> Bool {
        return pthread_mutex_trylock(&_lock) == 0
    }

    func unlock() {
        pthread_mutex_unlock(&_lock)
    }

    @discardableResult
    nonisolated func sync<R>(execute work: @Sendable () throws -> R) rethrows -> R {
        lock()
        defer {
            unlock()
        }
        return try work()
    }

    @discardableResult
    nonisolated func trySync<R>(execute work: () throws -> R) rethrows -> R {
        let locked = tryLock()
        defer {
            if locked {
                unlock()
            }
        }
        return try work()
    }
}
