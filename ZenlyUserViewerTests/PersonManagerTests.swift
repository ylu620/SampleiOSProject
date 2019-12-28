import XCTest
@testable import ZenlyUserViewer

class PersonManagerTests: XCTestCase {

    var connectionManagerMock: ConnectionManagerMock!
    var storageMock: PersonStorageMock!
    var subject: PersonManager!
    var testPersons: [Person]!
    var testPerson: Person!

    override func setUp() {
        connectionManagerMock = ConnectionManagerMock()
        storageMock = PersonStorageMock()
        storageMock.fileExists = true
        subject = PersonManager(
            connectionManager: connectionManagerMock,
            personStorage: storageMock
        )
        testPersons = [
            Person(
                uuid: "testUuid1",
                userName: "testUsername1",
                firstName: "testFirstname1",
                lastName: "testLastname1",
                gender: "testGender1",
                email: "testEmail1",
                cellPhone: "testCellphone1",
                age: 10,
                photoUrlThumbnail: "testThumbnail1",
                photoUrlMeidum: "testMedium1",
                photoUrlLarge: "testLarge1"
            ),
            Person(
                uuid: "testUuid2",
                userName: "testUsername2",
                firstName: "testFirstname2",
                lastName: "testLastname2",
                gender: "testGender2",
                email: "testEmail2",
                cellPhone: "testCellphone2",
                age: 11,
                photoUrlThumbnail: "testThumbnail2",
                photoUrlMeidum: "testMedium2",
                photoUrlLarge: "testLarge2"
            ),
        ]
        
        testPerson =  Person(
            uuid: "testUuid3",
            userName: "testUsername3",
            firstName: "testFirstname3",
            lastName: "testLastname3",
            gender: "testGender3",
            email: "testEmail3",
            cellPhone: "testCellphone3",
            age: 13,
            photoUrlThumbnail: "testThumbnail3",
            photoUrlMeidum: "testMedium3",
            photoUrlLarge: "testLarge3"
        )
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSave() {
        XCTAssertTrue(storageMock.persons.count == 0)

        subject.save(persons: testPersons)

        eventually {
            XCTAssertEqual(self.storageMock.persons, self.testPersons)
            XCTAssertTrue(self.storageMock.savePersonsCalled)
        }
    }

    func testGetAllPersons() {
        storageMock.persons = testPersons

        let emps = subject.getAllPersons()

        XCTAssertTrue(storageMock.getAllPersonsCalled)
        XCTAssertEqual(testPersons, emps)
    }

    func testGetPerson_succeeds_givenCorrectId(id: String) {
        storageMock.persons = testPersons

        let emp = subject.getPerson(with: "test1")

        XCTAssertTrue(storageMock.getAllPersonsCalled)
        XCTAssertEqual(testPersons[0], emp)
    }

    func testGetPerson_fails_givenIncorrectId(id: String) {
        storageMock.persons = testPersons

        let emp = subject.getPerson(with: "DoesNotExist")

        XCTAssertTrue(storageMock.getAllPersonsCalled)
        XCTAssertNil(emp)
    }

    func testReloadPersonList() {
        connectionManagerMock.startDataTaskCalled = false

        subject.reloadPersonList()

        eventually {
            XCTAssertTrue(self.connectionManagerMock.startDataTaskCalled)
        }
    }

    func testDownloadImageIfNeeded_shouldNotDownlod_whenAlreadyHasUrl() {
        XCTAssertFalse(connectionManagerMock.startDataTaskCalled)
        
        testPerson.localPhotoUrlThumbnail = URL(string: "localUrl")

        storageMock.persons = [testPerson]

        subject.downloadImageIfNeeded(
            for: testPerson,
            of: .thumbnail,
            completion: { _ in
                XCTAssertTrue(self.connectionManagerMock.startDataTaskCalled)
            }
        )
    }

    func testDownloadImageIfNeeded_shouldDownlod_givenNoURL() {
        subject.downloadImageIfNeeded(
            for: testPerson,
            of: .thumbnail,
            completion: { success in
                XCTAssertTrue(self.connectionManagerMock.startDataTaskCalled)
            }
        )
    }
}

// 3rd party helper function to help testing
// credit: https://gist.github.com/dduan/5507c1e6db78b6ee38d56896764e288c

extension XCTestCase {
    func eventually(timeout: TimeInterval = 0.01, closure: @escaping () -> Void) {
        let expectation = self.expectation(description: "")
        expectation.fulfillAfter(timeout)
        self.waitForExpectations(timeout: 60) { _ in
            closure()
        }
    }
}

extension XCTestExpectation {
    func fulfillAfter(_ time: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            self.fulfill()
        }
    }
}
