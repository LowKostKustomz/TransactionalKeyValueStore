//
//  DefaultKeyValuesStorageTests.swift
//  TransactionalKeyValueStoreTests
//
//  Created by Yehor Miroshnychenko on 3/27/23.
//

import XCTest
import Combine
@testable import TransactionalKeyValueStore

final class DefaultKeyValuesStorageTests: XCTestCase {
    
    private var cancellables: Set<AnyCancellable> = []
    
    func makeSUT() -> KeyValuesStorage {
        DefaultKeyValuesStorage()
    }
    
    func test_getContainer() {
        // GIVEN
        let sut = makeSUT()
        let container: KeyValuesStorageContainer = .mock12
        sut.save(container: container)
        
        // WHEN, THEN
        XCTAssertEqual(try sut.getContainer(), container)
    }
    
    func test_getContainer_shouldThrowNoContainer() {
        // GIVEN
        let sut = makeSUT()
        
        // WHEN, THEN
        checkNoContainer(in: sut)
    }
    
    func test_saveContainer() {
        // GIVEN
        let sut = makeSUT()
        let container: KeyValuesStorageContainer = .mock12
        checkNoContainer(in: sut)
        
        // WHEN
        sut.save(container: container)
        
        // THEN
        XCTAssertEqual(try sut.getContainer(), container)
    }
    
    func test_removeContainer() {
        // GIVEN
        let sut = makeSUT()
        let container: KeyValuesStorageContainer = .mock12
        sut.save(container: container)
        XCTAssertNoThrow(try sut.getContainer())
        
        // WHEN
        sut.removeContainer()
        
        // THEN
        checkNoContainer(in: sut)
    }
    
    func test_observeContainer() {
        // GIVEN
        let sut = makeSUT()
        let numberOfOperations: Int = 3
        let observeContainerExpectation = expectation(description: "observe container publisher")
        // There is always first event with current container value
        observeContainerExpectation.expectedFulfillmentCount = numberOfOperations + 1
        var receivedContainers: [KeyValuesStorageContainer?] = []
        
        sut
            .observeContainer()
            .sink { container in
                receivedContainers.append(container)
                observeContainerExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        // WHEN
        sut.save(container: .mock12)
        sut.removeContainer()
        sut.save(container: .mock123)
        
        wait(for: [observeContainerExpectation], timeout: 5.0)
        
        // THEN
        XCTAssertEqual(receivedContainers, [nil, .mock12, nil, .mock123])
        XCTAssertEqual(try sut.getContainer(), .mock123)
    }
    
    // MARK: Helpers
    
    /// Checks that `getContainer` method throws `KeyValuesStorageAccessError.noContainer`.
    private func checkNoContainer(
        in storage: KeyValuesStorage,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try storage.getContainer(),
            file: file,
            line: line
        ) { error in
            XCTAssertEqual(
                try? XCTUnwrap(error as? KeyValuesStorageAccessError),
                KeyValuesStorageAccessError.noContainer,
                file: file,
                line: line
            )
        }
    }
}
