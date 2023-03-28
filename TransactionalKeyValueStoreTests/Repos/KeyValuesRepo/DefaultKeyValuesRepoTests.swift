//
//  DefaultKeyValuesRepoTests.swift
//  TransactionalKeyValueStoreTests
//
//  Created by Yehor Miroshnychenko on 3/27/23.
//

import XCTest
@testable import TransactionalKeyValueStore

final class DefaultKeyValuesRepoTests: XCTestCase {
    
    func makeSUT(
        storage: KeyValuesStorage = DefaultKeyValuesStorage()
    ) -> KeyValuesRepo {
        DefaultKeyValuesRepo(
            storage: storage
        )
    }
    
    func test_getValueForKey_shouldThrowKeyNotSet() {
        // GIVEN
        let storageSpy: KeyValuesStorageSpy = .init()
        let sut = makeSUT(
            storage: storageSpy
        )
        storageSpy.stub(container: .init(keyValues: []))
        
        // WHEN, THEN
        checkKeyNotSet("key", in: sut)
    }
    
    func test_getValueForKey() {
        // GIVEN
        let storageSpy: KeyValuesStorageSpy = .init()
        let stubKeyValue: KeyValuesStorageContainer.KeyValue = .mock1
        let sut = makeSUT(
            storage: storageSpy
        )
        storageSpy.stub(container: .init(
            keyValues: [stubKeyValue])
        )
        
        // WHEN
        XCTAssertEqual(try sut.get(key: stubKeyValue.key), stubKeyValue.value)
    }
    
    func test_setValueForKey() {
        // GIVEN
        let stubKeyValue: KeyValuesStorageContainer.KeyValue = .mock1
        let sut = makeSUT()
        checkKeyNotSet(stubKeyValue.key, in: sut)
        
        // WHEN
        sut.set(value: stubKeyValue.value, for: stubKeyValue.key)
        
        // THEN
        XCTAssertEqual(try sut.get(key: stubKeyValue.key), stubKeyValue.value)
    }
    
    func test_deleteValueForKey() {
        // GIVEN
        let stubKeyValue: KeyValuesStorageContainer.KeyValue = .mock1
        let sut = makeSUT()
        sut.set(value: stubKeyValue.value, for: stubKeyValue.key)
        XCTAssertEqual(try sut.get(key: stubKeyValue.key), stubKeyValue.value)
        
        // WHEN
        sut.delete(key: stubKeyValue.key)
        
        // THEN
        checkKeyNotSet(stubKeyValue.key, in: sut)
    }
    
    func test_countValues() {
        // GIVEN
        let stubKeyValue1: KeyValuesStorageContainer.KeyValue = .init(
            key: "key1",
            value: "value"
        )
        let stubKeyValue2: KeyValuesStorageContainer.KeyValue = .init(
            key: "key2",
            value: "value"
        )
        let stubKeyValue3: KeyValuesStorageContainer.KeyValue = .init(
            key: "key3",
            value: "value2"
        )
        let storageSpy: KeyValuesStorageSpy = .init()
        let sut = makeSUT(storage: storageSpy)
        storageSpy.stub(
            container: .init(
                keyValues: [stubKeyValue1, stubKeyValue2, stubKeyValue3]
            )
        )
        
        // WHEN, THEN
        XCTAssertEqual(sut.count(value: "value"), 2)
    }
    
    // MARK: Transactions tests
    
    func test_beginTransaction() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN
        sut.begin()
        
        // THEN
        XCTAssertTrue(sut.transactionInProgress)
    }
    
    func test_commitTransaction_shouldThrowNoTransactionError() {
        // GIVEN
        let sut = makeSUT()
        XCTAssertFalse(sut.transactionInProgress)
        
        // WHEN, THEN
        checkNoTransaction(try sut.commit())
    }
    
    func test_commitTransaction() throws {
        // GIVEN
        let sut = makeSUT()
        sut.set(value: "bar", for: "FOO")
        sut.set(value: "bob", for: "ALICE")
        sut.set(value: "clyde", for: "BONNIE")
        
        XCTAssertEqual(
            sut.keyValuesContainer,
            .init(keyValues: [
                .init(key: "FOO", value: "bar"),
                .init(key: "ALICE", value: "bob"),
                .init(key: "BONNIE", value: "clyde")
            ])
        )
        
        sut.begin()
        XCTAssertTrue(sut.transactionInProgress)
        sut.set(value: "bar2", for: "FOO")
        sut.delete(key: "ALICE")
        sut.set(value: "bar2", for: "BONNIE")
        
        XCTAssertEqual(
            sut.keyValuesContainer,
            .init(keyValues: [
                .init(key: "FOO", value: "bar2"),
                .init(key: "BONNIE", value: "bar2")
            ])
        )
        
        // WHEN
        XCTAssertNoThrow(try sut.commit())
        
        // THEN
        XCTAssertFalse(sut.transactionInProgress)
        XCTAssertEqual(
            sut.keyValuesContainer,
            .init(keyValues: [
                .init(key: "FOO", value: "bar2"),
                .init(key: "BONNIE", value: "bar2")
            ])
        )
    }
    
    func test_rollbackTransaction_shouldThrowNoTransactionError() {
        // GIVEN
        let sut = makeSUT()
        XCTAssertFalse(sut.transactionInProgress)
        
        // WHEN, THEN
        checkNoTransaction(try sut.rollback())
    }
    
    func test_rollbackTransaction() throws {
        // GIVEN
        let sut = makeSUT()
        sut.set(value: "bar", for: "FOO")
        sut.set(value: "bob", for: "ALICE")
        sut.set(value: "clyde", for: "BONNIE")
        
        XCTAssertEqual(
            sut.keyValuesContainer,
            .init(keyValues: [
                .init(key: "FOO", value: "bar"),
                .init(key: "ALICE", value: "bob"),
                .init(key: "BONNIE", value: "clyde")
            ])
        )
        
        sut.begin()
        XCTAssertTrue(sut.transactionInProgress)
        sut.set(value: "bar2", for: "FOO")
        sut.delete(key: "ALICE")
        sut.set(value: "bar2", for: "BONNIE")
        
        XCTAssertEqual(
            sut.keyValuesContainer,
            .init(keyValues: [
                .init(key: "FOO", value: "bar2"),
                .init(key: "BONNIE", value: "bar2")
            ])
        )
        
        // WHEN
        XCTAssertNoThrow(try sut.rollback())
        
        // THEN
        XCTAssertFalse(sut.transactionInProgress)
        XCTAssertEqual(
            sut.keyValuesContainer,
            .init(keyValues: [
                .init(key: "FOO", value: "bar"),
                .init(key: "ALICE", value: "bob"),
                .init(key: "BONNIE", value: "clyde")
            ])
        )
    }
    
    // MARK: Nested transactions tests
    
    func test_beginNestedTransaction() {
        // GIVEN
        let sut = makeSUT()
        sut.begin()
        XCTAssertTrue(sut.transactionInProgress)
        
        // WHEN
        sut.begin()
        
        // THEN
        XCTAssertTrue(sut.transactionInProgress)
    }
    
    func test_commitNestedTransactionRollbackTransaction() {
        // GIVEN
        let sut = makeSUT()
        sut.set(value: "bar", for: "FOO")
        sut.set(value: "bob", for: "ALICE")
        sut.set(value: "clyde", for: "BONNIE")
        
        XCTAssertEqual(
            sut.keyValuesContainer,
            .init(keyValues: [
                .init(key: "FOO", value: "bar"),
                .init(key: "ALICE", value: "bob"),
                .init(key: "BONNIE", value: "clyde")
            ])
        )
        
        sut.begin()
        XCTAssertTrue(sut.transactionInProgress)
        sut.set(value: "bar2", for: "FOO")
        sut.delete(key: "ALICE")
        sut.set(value: "bar2", for: "BONNIE")
        
        XCTAssertEqual(
            sut.keyValuesContainer,
            .init(keyValues: [
                .init(key: "FOO", value: "bar2"),
                .init(key: "BONNIE", value: "bar2")
            ])
        )
        
        sut.begin()
        XCTAssertTrue(sut.transactionInProgress)
        sut.set(value: "bar3", for: "FOO")
        sut.set(value: "bob2", for: "ALICE")
        sut.set(value: "clyde2", for: "BONNIE")
        
        XCTAssertEqual(
            sut.keyValuesContainer,
            .init(keyValues: [
                .init(key: "FOO", value: "bar3"),
                .init(key: "BONNIE", value: "clyde2"),
                .init(key: "ALICE", value: "bob2")
            ])
        )
        
        // WHEN, THEN
        XCTAssertNoThrow(try sut.commit())
        XCTAssertTrue(sut.transactionInProgress)
        
        XCTAssertEqual(
            sut.keyValuesContainer,
            .init(keyValues: [
                .init(key: "FOO", value: "bar3"),
                .init(key: "BONNIE", value: "clyde2"),
                .init(key: "ALICE", value: "bob2")
            ])
        )
        
        XCTAssertNoThrow(try sut.rollback())
        XCTAssertFalse(sut.transactionInProgress)
        
        XCTAssertEqual(
            sut.keyValuesContainer,
            .init(keyValues: [
                .init(key: "FOO", value: "bar"),
                .init(key: "ALICE", value: "bob"),
                .init(key: "BONNIE", value: "clyde")
            ])
        )
    }
    
    func test_rollbackNestedTransactionCommitTransaction() {
        // GIVEN
        let sut = makeSUT()
        sut.set(value: "bar", for: "FOO")
        sut.set(value: "bob", for: "ALICE")
        sut.set(value: "clyde", for: "BONNIE")
        
        XCTAssertEqual(
            sut.keyValuesContainer,
            .init(keyValues: [
                .init(key: "FOO", value: "bar"),
                .init(key: "ALICE", value: "bob"),
                .init(key: "BONNIE", value: "clyde")
            ])
        )
        
        sut.begin()
        XCTAssertTrue(sut.transactionInProgress)
        sut.set(value: "bar2", for: "FOO")
        sut.delete(key: "ALICE")
        sut.set(value: "bar2", for: "BONNIE")
        
        XCTAssertEqual(
            sut.keyValuesContainer,
            .init(keyValues: [
                .init(key: "FOO", value: "bar2"),
                .init(key: "BONNIE", value: "bar2")
            ])
        )
        
        sut.begin()
        XCTAssertTrue(sut.transactionInProgress)
        sut.set(value: "bar3", for: "FOO")
        sut.set(value: "bob2", for: "ALICE")
        sut.set(value: "clyde2", for: "BONNIE")
        
        XCTAssertEqual(
            sut.keyValuesContainer,
            .init(keyValues: [
                .init(key: "FOO", value: "bar3"),
                .init(key: "BONNIE", value: "clyde2"),
                .init(key: "ALICE", value: "bob2")
            ])
        )
        
        // WHEN, THEN
        XCTAssertNoThrow(try sut.rollback())
        XCTAssertTrue(sut.transactionInProgress)
        
        XCTAssertEqual(
            sut.keyValuesContainer,
            .init(keyValues: [
                .init(key: "FOO", value: "bar2"),
                .init(key: "BONNIE", value: "bar2")
            ])
        )
        
        XCTAssertNoThrow(try sut.commit())
        XCTAssertFalse(sut.transactionInProgress)
        
        XCTAssertEqual(
            sut.keyValuesContainer,
            .init(keyValues: [
                .init(key: "FOO", value: "bar2"),
                .init(key: "BONNIE", value: "bar2")
            ])
        )
    }
    
    func test_rollbackNestedTransactionRollbackTransaction() {
        // GIVEN
        let sut = makeSUT()
        sut.set(value: "bar", for: "FOO")
        sut.set(value: "bob", for: "ALICE")
        sut.set(value: "clyde", for: "BONNIE")
        
        XCTAssertEqual(
            sut.keyValuesContainer,
            .init(keyValues: [
                .init(key: "FOO", value: "bar"),
                .init(key: "ALICE", value: "bob"),
                .init(key: "BONNIE", value: "clyde")
            ])
        )
        
        sut.begin()
        XCTAssertTrue(sut.transactionInProgress)
        sut.set(value: "bar2", for: "FOO")
        sut.delete(key: "ALICE")
        sut.set(value: "bar2", for: "BONNIE")
        
        XCTAssertEqual(
            sut.keyValuesContainer,
            .init(keyValues: [
                .init(key: "FOO", value: "bar2"),
                .init(key: "BONNIE", value: "bar2")
            ])
        )
        
        sut.begin()
        XCTAssertTrue(sut.transactionInProgress)
        sut.set(value: "bar3", for: "FOO")
        sut.set(value: "bob2", for: "ALICE")
        sut.set(value: "clyde2", for: "BONNIE")
        
        XCTAssertEqual(
            sut.keyValuesContainer,
            .init(keyValues: [
                .init(key: "FOO", value: "bar3"),
                .init(key: "BONNIE", value: "clyde2"),
                .init(key: "ALICE", value: "bob2")
            ])
        )
        
        // WHEN, THEN
        XCTAssertNoThrow(try sut.rollback())
        XCTAssertTrue(sut.transactionInProgress)
        
        XCTAssertEqual(
            sut.keyValuesContainer,
            .init(keyValues: [
                .init(key: "FOO", value: "bar2"),
                .init(key: "BONNIE", value: "bar2")
            ])
        )
        
        XCTAssertNoThrow(try sut.rollback())
        XCTAssertFalse(sut.transactionInProgress)
        
        XCTAssertEqual(
            sut.keyValuesContainer,
            .init(keyValues: [
                .init(key: "FOO", value: "bar"),
                .init(key: "ALICE", value: "bob"),
                .init(key: "BONNIE", value: "clyde")
            ])
        )
    }
    
    func test_commitNestedTransactionCommitTransaction() {
        // GIVEN
        let sut = makeSUT()
        sut.set(value: "bar", for: "FOO")
        sut.set(value: "bob", for: "ALICE")
        sut.set(value: "clyde", for: "BONNIE")
        
        XCTAssertEqual(
            sut.keyValuesContainer,
            .init(keyValues: [
                .init(key: "FOO", value: "bar"),
                .init(key: "ALICE", value: "bob"),
                .init(key: "BONNIE", value: "clyde")
            ])
        )
        
        sut.begin()
        XCTAssertTrue(sut.transactionInProgress)
        sut.set(value: "bar2", for: "FOO")
        sut.delete(key: "ALICE")
        sut.set(value: "bar2", for: "BONNIE")
        
        XCTAssertEqual(
            sut.keyValuesContainer,
            .init(keyValues: [
                .init(key: "FOO", value: "bar2"),
                .init(key: "BONNIE", value: "bar2")
            ])
        )
        
        sut.begin()
        XCTAssertTrue(sut.transactionInProgress)
        sut.set(value: "bar3", for: "FOO")
        sut.set(value: "bob2", for: "ALICE")
        sut.set(value: "clyde2", for: "BONNIE")
        
        XCTAssertEqual(
            sut.keyValuesContainer,
            .init(keyValues: [
                .init(key: "FOO", value: "bar3"),
                .init(key: "BONNIE", value: "clyde2"),
                .init(key: "ALICE", value: "bob2")
            ])
        )
        
        // WHEN, THEN
        XCTAssertNoThrow(try sut.commit())
        XCTAssertTrue(sut.transactionInProgress)
        
        XCTAssertEqual(
            sut.keyValuesContainer,
            .init(keyValues: [
                .init(key: "FOO", value: "bar3"),
                .init(key: "BONNIE", value: "clyde2"),
                .init(key: "ALICE", value: "bob2")
            ])
        )
        
        XCTAssertNoThrow(try sut.commit())
        XCTAssertFalse(sut.transactionInProgress)
        
        XCTAssertEqual(
            sut.keyValuesContainer,
            .init(keyValues: [
                .init(key: "FOO", value: "bar3"),
                .init(key: "BONNIE", value: "clyde2"),
                .init(key: "ALICE", value: "bob2")
            ])
        )
    }
    
    // MARK: Helpers
    
    /// Checks that `get(key:)` method throws `KeyValuesRepoAccessError.keyNotSet`.
    private func checkKeyNotSet(
        _ key: KeyValuesRepo.Key,
        in repo: KeyValuesRepo,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try repo.get(key: key),
            file: file,
            line: line
        ) { error in
            XCTAssertEqual(
                try? XCTUnwrap(error as? KeyValuesRepoAccessError),
                KeyValuesRepoAccessError.keyNotSet,
                file: file,
                line: line
            )
        }
    }
    
    /// Checks that `get(key:)` method throws `KeyValuesRepoAccessError.keyNotSet`.
    private func checkNoTransaction<T>(
        _ expression: @escaping @autoclosure () throws -> T,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try expression(),
            file: file,
            line: line
        ) { error in
            XCTAssertEqual(
                try? XCTUnwrap(error as? KeyValuesRepoTransactionError),
                KeyValuesRepoTransactionError.noTransaction,
                file: file,
                line: line
            )
        }
    }
}
