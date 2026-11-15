//
//  AdvertsViewControllerSnapshotTests.swift
//  ArmonyTests
//

import XCTest
@testable import Armony
import SnapshotTesting

final class AdvertsViewControllerSnapshotTests: SnapshotTestCase {

    private var sut: AdvertsViewController!
    private var navigationController: UINavigationController!
    private var viewModel: AdvertsViewModel!
    private var mockService: MockRestService!
    private var mockBannerService: MockRestService!

    override func setUp() {
        super.setUp()
        // `setHidden(_:animated:)` and the empty state use UIView transitions; finish them immediately.
        UIView.setAnimationsEnabled(false)

        mockService = MockRestService(backend: .factory())
        mockBannerService = MockRestService(backend: .factory())
    }

    override func tearDown() {
        UIView.setAnimationsEnabled(true)
        sut = nil
        navigationController = nil
        viewModel = nil
        mockService = nil
        mockBannerService = nil
        super.tearDown()
    }

    func testAdvertsLoaded() throws {
        try stubHomeData(bannersJSON: Self.inactiveBannersJSON, advertsJSON: Self.advertsJSON)

        loadAndWaitForAdverts()

        assertSnapshot(of: navigationController, as: .image(on: .iPhone13))
    }

    func testEmptyState() throws {
        try stubHomeData(bannersJSON: Self.inactiveBannersJSON, advertsJSON: Self.emptyAdvertsJSON)

        loadAndWaitForAdverts()

        assertSnapshot(of: navigationController, as: .image(on: .iPhone13))
    }

    func testFiltersApplied() throws {
        try stubHomeData(bannersJSON: Self.inactiveBannersJSON, advertsJSON: Self.advertsJSON)
        loadAndWaitForAdverts()

        let filters = FilterViewModel.Filters(
            advert: FilterViewModel.Filter(id: 1, title: "Musician"),
            location: FilterViewModel.Filter(id: 34, title: "Istanbul")
        )
        sut.applyButtonTapped(filters: filters)
        waitForAdverts()

        assertSnapshot(of: navigationController, as: .image(on: .iPhone13))
    }

    // MARK: - Banners

    func testBannersInTR() throws {
        try stubHomeData(bannersJSON: Self.activeBannersJSON, advertsJSON: Self.advertsJSON)

        loadAndWaitForAdverts(regionCode: "TR")

        assertSnapshot(of: navigationController, as: .image(on: .iPhone13))
    }

    func testBannersInTRSecondBannerVisible() throws {
        try stubHomeData(bannersJSON: Self.activeBannersJSON, advertsJSON: Self.advertsJSON)
        loadAndWaitForAdverts(regionCode: "TR")

        scrollBannerSlider(toItem: 1)

        assertSnapshot(of: navigationController, as: .image(on: .iPhone13))
    }

    func testBannersOutsideTRDropsFirstBanner() throws {
        try stubHomeData(bannersJSON: Self.activeBannersJSON, advertsJSON: Self.advertsJSON)

        loadAndWaitForAdverts(regionCode: "US")

        assertSnapshot(of: navigationController, as: .image(on: .iPhone13))
    }

    func testBannersWithEmptyAdverts() throws {
        try stubHomeData(bannersJSON: Self.activeBannersJSON, advertsJSON: Self.emptyAdvertsJSON)

        loadAndWaitForAdverts(regionCode: "TR")

        assertSnapshot(of: navigationController, as: .image(on: .iPhone13))
    }

    // MARK: - Helpers

    private func loadAndWaitForAdverts(regionCode: String? = "US") {
        sut = AdvertsViewController.controller()
        viewModel = AdvertsViewModel(
            view: sut,
            messageCountSocketHandler: MockMessageCountSocketHandler(),
            authenticator: MockAuthenticationService(),
            defaults: MockDefaults(),
            appLaunchService: MockAppLaunchService(),
            regionCode: regionCode,
            bannerService: mockBannerService,
            service: mockService
        )
        viewModel.coordinator = MockAdvertsCoordinator()
        sut.viewModel = viewModel
        navigationController = UINavigationController(rootViewController: sut)

        sut.loadViewIfNeeded()
        waitForAdverts()
    }

    /// Pages the banner slider like a swipe would; `BannerSliderView` updates its counter in `scrollViewDidScroll`.
    /// The view is laid out at the snapshot width first, so the page offset matches the recorded image.
    private func scrollBannerSlider(toItem item: Int, file: StaticString = #filePath, line: UInt = #line) {
        navigationController.view.frame = CGRect(origin: .zero, size: ViewImageConfig.iPhone13.size!)
        navigationController.view.layoutIfNeeded()

        guard let bannerSliderView: BannerSliderView = sut.view.firstSubview(),
              let collectionView: UICollectionView = bannerSliderView.firstSubview() else {
            return XCTFail("Banner slider is not visible", file: file, line: line)
        }
        collectionView.scrollToItem(at: IndexPath(item: item, section: .zero), at: .left, animated: false)
        navigationController.view.layoutIfNeeded()
    }

    /// `fetchAdverts()` runs in a `Task` and hops back to main via `safeSync`,
    /// so spin the main run loop until the activity indicator is stopped.
    private func waitForAdverts(timeout: TimeInterval = 2.0, file: StaticString = #filePath, line: UInt = #line) {
        let deadline = Date().addingTimeInterval(timeout)
        while sut.view.activityIndicatorView.isAnimating, Date() < deadline {
            RunLoop.main.run(until: Date().addingTimeInterval(0.01))
        }
        XCTAssertFalse(sut.view.activityIndicatorView.isAnimating, "Adverts did not load in time", file: file, line: line)
    }

    private func stubHomeData(bannersJSON: String, advertsJSON: String) throws {
        mockBannerService.stubbedResult = try decode(bannersJSON, as: RestObjectResponse<BannerSliderResponse>.self)
        mockService.stubbedResult = try decode(advertsJSON, as: RestArrayResponse<Advert>.self)
    }

    private func decode<R: Decodable>(_ json: String, as type: R.Type) throws -> R {
        return try JSONDecoder().decode(R.self, from: Data(json.utf8))
    }
}

// MARK: - UIView

private extension UIView {
    func firstSubview<T: UIView>() -> T? {
        for subview in subviews {
            if let match = subview as? T ?? subview.firstSubview() {
                return match
            }
        }
        return nil
    }
}

// MARK: - Fixtures

/// Image URLs are rendered by `ColoredRemoteImageLoader` (installed by `SnapshotTestCase`), never fetched.
private extension AdvertsViewControllerSnapshotTests {

    static let inactiveBannersJSON = """
    {
        "data": { "isActive": false, "banners": [] },
        "error": null,
        "metadata": null
    }
    """

    static let activeBannersJSON = """
    {
        "data": {
            "isActive": true,
            "banners": [
                {
                    "title": "Find your band",
                    "image": "https://example.com/banners/1.png",
                    "backgroundColor": "#7B61FF",
                    "deeplink": "armony://adverts"
                },
                {
                    "title": "Go premium",
                    "image": "https://example.com/banners/2.png",
                    "backgroundColor": "#E64980",
                    "deeplink": "armony://adverts"
                },
                {
                    "title": "Book a studio",
                    "image": "https://example.com/banners/3.png",
                    "backgroundColor": "#9EF3FF",
                    "deeplink": "armony://adverts"
                }
            ]
        },
        "error": null,
        "metadata": null
    }
    """

    static let emptyAdvertsJSON = """
    { "data": [], "error": null, "metadata": null }
    """

    static let advertsJSON = """
    {
        "data": [
            {
                "id": 1,
                "city": { "id": 34, "name": "Istanbul" },
                "description": "Looking for a guitarist",
                "adType": { "id": 1, "name": "Band", "colorCode": "#3498DB", "skillTitle": "Looking for" },
                "genres": [],
                "isActive": true,
                "skills": [
                    { "id": 7, "imageUrl": "https://example.com/skills/7.png", "name": "Guitar", "colorCode": null },
                    { "id": 9, "imageUrl": "https://example.com/skills/9.png", "name": "Drums", "colorCode": null }
                ],
                "user": {
                    "id": "user1",
                    "name": "Jane Doe",
                    "photoUrl": "https://example.com/users/1.png",
                    "email": null,
                    "token": null
                },
                "status": "active",
                "updatedAt": "2026-01-01",
                "serviceTypes": [],
                "external_link": null
            },
            {
                "id": 2,
                "city": { "id": 6, "name": "Ankara" },
                "description": "Rehearsal studio for rent",
                "adType": { "id": 3, "name": "Rental", "colorCode": "#E67E22", "skillTitle": "Offering" },
                "genres": [],
                "isActive": true,
                "skills": [
                    { "id": 12, "imageUrl": null, "name": "Studio", "colorCode": null }
                ],
                "user": {
                    "id": "user2",
                    "name": "John Smith",
                    "photoUrl": "https://example.com/users/2.png",
                    "email": null,
                    "token": null
                },
                "status": "active",
                "updatedAt": "2026-01-02",
                "serviceTypes": [],
                "external_link": null
            },
            {
                "id": 3,
                "city": { "id": 35, "name": "Izmir" },
                "description": "Piano lessons",
                "adType": { "id": 4, "name": "Lessons", "colorCode": "#9B59B6", "skillTitle": "Teaching" },
                "genres": [],
                "isActive": true,
                "skills": [
                    { "id": 8, "imageUrl": null, "name": "Piano", "colorCode": null }
                ],
                "user": { "id": "user3", "name": "Alex Taylor", "photoUrl": null, "email": null, "token": null },
                "status": "active",
                "updatedAt": "2026-01-03",
                "serviceTypes": [],
                "external_link": null
            }
        ],
        "error": null,
        "metadata": null
    }
    """
}
