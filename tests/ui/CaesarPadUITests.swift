import UIKit
import XCTest

final class CaesarPadUITests: XCTestCase {
    private let app = XCUIApplication(bundleIdentifier: "com.chrissotraidis.caesarpad")

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .landscapeLeft
    }

    private func point(_ x: CGFloat, _ y: CGFloat) -> XCUICoordinate {
        app.coordinate(withNormalizedOffset: CGVector(dx: x, dy: y))
    }

    @discardableResult
    private func capture(_ name: String) -> XCUIScreenshot {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        return screenshot
    }

    private func settle(_ seconds: TimeInterval = 1) {
        Thread.sleep(forTimeInterval: seconds)
    }

    private func useTraditionalTouchControls() {
        let pencil = app.buttons["caesarpad.pencil-mode"]
        XCTAssertTrue(pencil.waitForExistence(timeout: 5))
        if pencil.value as? String != "Off, traditional touch controls" {
            pencil.tap()
        }
        XCTAssertEqual(pencil.value as? String, "Off, traditional touch controls")
    }

    private func pixels(
        in screenshot: XCUIScreenshot,
        normalizedRect: CGRect,
        width: Int = 64,
        height: Int = 64
    ) -> [UInt8] {
        let screenshotImage = screenshot.image
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let orientedImage = UIGraphicsImageRenderer(
            size: screenshotImage.size,
            format: format
        ).image { _ in
            screenshotImage.draw(in: CGRect(origin: .zero, size: screenshotImage.size))
        }

        guard let image = orientedImage.cgImage else {
            XCTFail("Screenshot has no CGImage")
            return []
        }

        let cropRect = CGRect(
            x: normalizedRect.minX * CGFloat(image.width),
            y: normalizedRect.minY * CGFloat(image.height),
            width: normalizedRect.width * CGFloat(image.width),
            height: normalizedRect.height * CGFloat(image.height)
        ).integral

        guard let cropped = image.cropping(to: cropRect) else {
            XCTFail("Unable to crop screenshot")
            return []
        }

        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        let context = CGContext(
            data: &bytes,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        context?.interpolationQuality = .none
        context?.draw(cropped, in: CGRect(x: 0, y: 0, width: width, height: height))
        return bytes
    }

    private func visualDifference(
        _ before: XCUIScreenshot,
        _ after: XCUIScreenshot,
        in rect: CGRect
    ) -> Double {
        let first = pixels(in: before, normalizedRect: rect)
        let second = pixels(in: after, normalizedRect: rect)
        guard first.count == second.count, !first.isEmpty else { return 0 }

        var difference = 0
        for index in stride(from: 0, to: first.count, by: 4) {
            difference += abs(Int(first[index]) - Int(second[index]))
            difference += abs(Int(first[index + 1]) - Int(second[index + 1]))
            difference += abs(Int(first[index + 2]) - Int(second[index + 2]))
        }
        return Double(difference) / Double(first.count / 4 * 3 * 255)
    }

    func testPlayableMissionFlow() {
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15))
        useTraditionalTouchControls()
        XCTAssertGreaterThan(app.frame.width, app.frame.height)
        capture("00-landscape-launch")

        // Upstream asks twice when custom save directories have not been chosen.
        point(0.527, 0.453).tap()
        settle(0.5)
        point(0.501, 0.523).tap()
        settle(3)

        capture("01-title")
        point(0.503, 0.529).tap()
        settle(2)
        capture("02-main-menu")

        point(0.501, 0.325).tap()
        settle()
        point(0.762, 0.881).tap()
        settle(2)
        capture("03-mission-briefing")

        point(0.757, 0.862).tap()
        settle(4)
        point(0.666, 0.602).tap()
        settle(2)
        let mission = capture("04-mission-started")

        point(0.839, 0.568).tap()
        settle()
        let selected = capture("05-tap-selected-housing")
        let selectionDifference = visualDifference(
            mission,
            selected,
            in: CGRect(x: 0.80, y: 0.50, width: 0.18, height: 0.16)
        )
        XCTAssertGreaterThan(selectionDifference, 0.01, "Tap did not visibly select the housing tool")

        point(0.385, 0.244).tap()
        settle(0.5)
        point(0.385, 0.244).tap()
        settle()
        let placed = capture("06-building-placed")
        let placementDifference = visualDifference(
            selected,
            placed,
            in: CGRect(x: 0.29, y: 0.14, width: 0.20, height: 0.20)
        )
        XCTAssertGreaterThan(placementDifference, 0.002, "Tap did not visibly place a building")

        let cancelBefore = capture("07-cancel-before")
        let cancelCandidates: [(CGFloat, CGFloat)] = [
            (0.727, 0.090),
            (0.737, 0.090),
            (0.747, 0.090),
            (0.727, 0.100),
            (0.737, 0.100),
            (0.747, 0.100),
            (0.727, 0.110),
            (0.737, 0.110),
            (0.747, 0.110),
        ]
        var cancelDifference = 0.0
        for candidate in cancelCandidates {
            point(candidate.0, candidate.1).tap()
            settle(0.25)
            let afterCandidate = XCUIScreen.main.screenshot()
            cancelDifference = visualDifference(
                cancelBefore,
                afterCandidate,
                in: CGRect(x: 0.69, y: 0.05, width: 0.10, height: 0.12)
            )
            if cancelDifference > 0.02 {
                break
            }
        }
        XCTAssertGreaterThan(cancelDifference, 0.02, "Construction cancel did not respond to touch")
        let beforePan = capture("07-pan-before")
        point(0.364, 0.423).press(
            forDuration: 0.2,
            thenDragTo: point(0.597, 0.562),
            withVelocity: .slow,
            thenHoldForDuration: 0.1
        )
        settle()
        let afterPan = capture("08-pan-after")
        let panDifference = visualDifference(
            beforePan,
            afterPan,
            in: CGRect(x: 0.05, y: 0.08, width: 0.72, height: 0.75)
        )
        XCTAssertGreaterThan(panDifference, 0.08, "Drag did not visibly pan the city map")

        let speedBefore = capture("09-speed-before")
        point(0.855, 0.930).tap()
        settle()
        let speedAfter = capture("10-speed-changed")
        let speedDifference = visualDifference(
            speedBefore,
            speedAfter,
            in: CGRect(x: 0.80, y: 0.88, width: 0.18, height: 0.11)
        )
        XCTAssertGreaterThan(speedDifference, 0.0005, "Game speed was not reachable by touch")

        point(0.958, 0.950).tap()
        settle()
        let pauseStart = capture("11-paused")
        settle(3)
        let pauseHeld = capture("12-pause-held")
        let clockDifference = visualDifference(
            pauseStart,
            pauseHeld,
            in: CGRect(x: 0.54, y: 0.0, width: 0.20, height: 0.06)
        )
        XCTAssertLessThan(clockDifference, 0.01, "Game clock changed after tapping the in-game pause control")
        point(0.958, 0.950).tap()
    }

    func testScaledInterfaceAndVisibleCursor() {
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15))
        useTraditionalTouchControls()
        XCTAssertGreaterThan(app.frame.width, app.frame.height)

        point(0.527, 0.453).tap()
        settle(0.5)
        point(0.501, 0.523).tap()
        settle(3)
        point(0.503, 0.529).tap()
        settle(2)

        let cursorBefore = capture("30-scaled-main-menu")
        point(0.150, 0.150).tap()
        settle(0.5)
        let cursorAfter = capture("31-visible-touch-cursor")
        XCTAssertGreaterThan(
            visualDifference(
                cursorBefore,
                cursorAfter,
                in: CGRect(x: 0.12, y: 0.11, width: 0.09, height: 0.12)
            ),
            0.002,
            "Touch did not leave a visible cursor at the tapped position"
        )

        point(0.501, 0.325).tap()
        settle(2)
        capture("32-campaign-selection")

        point(0.762, 0.881).tap()
        settle(2)
        capture("33-mission-briefing")

        point(0.757, 0.862).tap()
        settle(4)
        capture("34-city-entry")
    }

    func testControlsHelpExplainsGestures() {
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15))
        useTraditionalTouchControls()
        let help = app.buttons["caesarpad.help"]
        XCTAssertTrue(help.waitForExistence(timeout: 5))
        XCTAssertTrue(help.isHittable)
        help.tap()

        let controls = app.alerts["CaesarPad Controls"]
        XCTAssertTrue(controls.waitForExistence(timeout: 5))
        XCTAssertTrue(controls.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "Drag two fingers together: pan the map")).firstMatch.exists)
        XCTAssertTrue(controls.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "Pinch: zoom")).firstMatch.exists)
        XCTAssertTrue(controls.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "cannot be group-selected")).firstMatch.exists)
        XCTAssertTrue(controls.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "Game speed panel at bottom-right")).firstMatch.exists)
        capture("35-controls-help")
        controls.buttons["Got it"].tap()
        XCTAssertFalse(controls.exists)
    }

    func testPencilModeTogglePersistsAndUpdatesHelp() {
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15))
        let pencil = app.buttons["caesarpad.pencil-mode"]
        XCTAssertTrue(pencil.waitForExistence(timeout: 5))
        XCTAssertTrue(pencil.isHittable)

        if (pencil.value as? String) != "Off, traditional touch controls" {
            pencil.tap()
        }
        XCTAssertEqual(pencil.value as? String, "Off, traditional touch controls")
        pencil.tap()
        XCTAssertEqual(pencil.value as? String, "On")

        app.terminate()
        app.launch()
        let persistedPencil = app.buttons["caesarpad.pencil-mode"]
        XCTAssertTrue(persistedPencil.waitForExistence(timeout: 5))
        XCTAssertEqual(persistedPencil.value as? String, "On")

        app.buttons["caesarpad.help"].tap()
        let controls = app.alerts["CaesarPad Controls"]
        XCTAssertTrue(controls.waitForExistence(timeout: 5))
        XCTAssertTrue(controls.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "Pencil: select, inspect, and place")).firstMatch.exists)
        XCTAssertTrue(controls.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "Finger taps cannot change the city")).firstMatch.exists)
        capture("36-pencil-controls")
        controls.buttons["Got it"].tap()

        persistedPencil.tap()
        XCTAssertEqual(persistedPencil.value as? String, "Off, traditional touch controls")
    }

    func testMinimalTouchControls() {
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15))
        useTraditionalTouchControls()
        XCTAssertGreaterThan(app.frame.width, app.frame.height)
        XCTAssertFalse(app.buttons["caesarpad.pause"].exists)
        let canvas = app.otherElements["caesarpad.canvas"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 5))
        XCTAssertGreaterThan(canvas.frame.width, canvas.frame.height)
        capture("20-touch-landscape")

        point(0.527, 0.453).tap()
        settle(0.5)
        point(0.501, 0.523).tap()
        settle(3)
        point(0.503, 0.529).tap()
        settle(2)
        point(0.501, 0.325).tap()
        settle()
        point(0.762, 0.881).tap()
        settle(2)
        point(0.757, 0.862).tap()
        settle(4)
        point(0.666, 0.602).tap()
        settle(2)
        let mission = capture("21-touch-mission")

        point(0.839, 0.568).tap()
        settle()
        let tapSelected = capture("22-tap-selected")
        XCTAssertGreaterThan(
            visualDifference(
                mission,
                tapSelected,
                in: CGRect(x: 0.80, y: 0.50, width: 0.18, height: 0.16)
            ),
            0.01,
            "Tap did not map to the housing button"
        )

        let twoFingerBefore = capture("24-two-finger-before")
        canvas.twoFingerTap()
        settle()
        let twoFingerAfter = capture("25-two-finger-right-click")
        XCTAssertGreaterThan(
            visualDifference(
                twoFingerBefore,
                twoFingerAfter,
                in: CGRect(x: 0.69, y: 0.05, width: 0.10, height: 0.12)
            ),
            0.02,
            "Two-finger tap did not map to alternate right-click tool cancel"
        )
        capture("25-two-finger-right-click-complete")

        point(0.839, 0.568).tap()
        settle()
        let longPressBefore = capture("25a-long-press-before")
        point(0.450, 0.420).press(forDuration: 0.8)
        settle()
        let longPressAfter = capture("25b-long-press-right-click")
        XCTAssertGreaterThan(
            visualDifference(
                longPressBefore,
                longPressAfter,
                in: CGRect(x: 0.69, y: 0.05, width: 0.10, height: 0.12)
            ),
            0.02,
            "Long press did not map to right-click tool cancel"
        )

        let panBefore = capture("26-drag-before")
        point(0.364, 0.423).press(
            forDuration: 0.2,
            thenDragTo: point(0.597, 0.562),
            withVelocity: .slow,
            thenHoldForDuration: 0.1
        )
        settle()
        let panAfter = capture("27-drag-panned")
        XCTAssertGreaterThan(
            visualDifference(
                panBefore,
                panAfter,
                in: CGRect(x: 0.05, y: 0.08, width: 0.72, height: 0.75)
            ),
            0.06,
            "One-finger drag did not pan the map"
        )

        let pinchBefore = capture("28-pinch-before")
        canvas.pinch(withScale: 0.5, velocity: -1.0)
        settle(2)
        var pinchAfter = capture("29-pinch-zoomed-out")
        var pinchDifference = visualDifference(
            pinchBefore,
            pinchAfter,
            in: CGRect(x: 0.05, y: 0.08, width: 0.72, height: 0.75)
        )
        if pinchDifference <= 0.04 {
            let reversePinchBefore = pinchAfter
            canvas.pinch(withScale: 1.5, velocity: 1.0)
            settle(2)
            pinchAfter = capture("29a-pinch-zoomed-in")
            pinchDifference = visualDifference(
                reversePinchBefore,
                pinchAfter,
                in: CGRect(x: 0.05, y: 0.08, width: 0.72, height: 0.75)
            )
        }
        XCTAssertGreaterThan(
            pinchDifference,
            0.04,
            "Pinch did not visibly change Augustus zoom"
        )

        capture("30-game-pause-before")
        point(0.958, 0.950).tap()
        settle()
        let pauseStart = capture("31-game-pause-after")
        settle(3)
        let pauseHeld = capture("31a-game-pause-held")
        XCTAssertLessThan(
            visualDifference(
                pauseStart,
                pauseHeld,
                in: CGRect(x: 0.54, y: 0.0, width: 0.20, height: 0.06)
            ),
            0.01,
            "Game clock changed after tapping the in-game pause control"
        )
        point(0.958, 0.950).tap()
        settle()
        capture("32-game-resume-after")
    }

    func testTopControlsStayAtTopRight() {
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15))
        let pencil = app.buttons["caesarpad.pencil-mode"]
        let help = app.buttons["caesarpad.help"]
        XCTAssertTrue(pencil.waitForExistence(timeout: 5))
        XCTAssertTrue(help.waitForExistence(timeout: 5))
        XCTAssertLessThan(pencil.frame.maxY, app.frame.height * 0.08)
        XCTAssertLessThan(help.frame.maxY, app.frame.height * 0.08)
        XCTAssertGreaterThan(pencil.frame.minX, app.frame.width * 0.90)
        XCTAssertLessThanOrEqual(help.frame.maxX, app.frame.width - 8)
        capture("37-top-right-controls")
    }

    func testPrepareLifecycleMission() {
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15))
        useTraditionalTouchControls()
        point(0.527, 0.453).tap()
        settle(0.5)
        point(0.501, 0.523).tap()
        settle(3)
        point(0.503, 0.529).tap()
        settle(2)
        point(0.501, 0.325).tap()
        settle()
        point(0.762, 0.881).tap()
        settle(2)
        point(0.757, 0.862).tap()
        settle(4)
        point(0.666, 0.602).tap()
        settle(2)

        XCTAssertFalse(app.buttons["caesarpad.pause"].exists)
        XCTAssertTrue(app.buttons["caesarpad.help"].exists)
        capture("40-lifecycle-city-ready")
    }

    func testVerifyLifecycleResume() {
        app.activate()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15))
        XCTAssertTrue(app.buttons["caesarpad.help"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["caesarpad.pause"].exists)
        capture("41-lifecycle-city-resumed")
    }

    func testDevelopedValentiaDemoSaveLoads() {
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15))
        useTraditionalTouchControls()
        point(0.527, 0.453).tap()
        settle(0.5)
        point(0.501, 0.523).tap()
        settle(3)
        point(0.503, 0.529).tap()
        settle(2)

        point(0.501, 0.405).tap()
        settle(3)
        let saveList = capture("50-valentia-save-list")

        point(0.300, 0.290).tap()
        settle(0.5)
        point(0.300, 0.290).tap()
        settle(2)
        let selectedSave = capture("50a-valentia-save-selected")
        XCTAssertGreaterThan(
            visualDifference(
                saveList,
                selectedSave,
                in: CGRect(x: 0.48, y: 0.15, width: 0.40, height: 0.68)
            ),
            0.01,
            "Selecting the Valentia demo save did not show its city preview"
        )

        point(0.755, 0.810).tap()
        settle(8)
        let developedCity = capture("51-valentia-developed-city")
        XCTAssertGreaterThan(
            visualDifference(
                selectedSave,
                developedCity,
                in: CGRect(x: 0.05, y: 0.08, width: 0.90, height: 0.82)
            ),
            0.08,
            "The developed Valentia city did not replace the load dialog"
        )
    }

    func testDevelopedValentiaSurvivesBackgroundCycles() {
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15))
        useTraditionalTouchControls()
        point(0.527, 0.453).tap()
        settle(0.5)
        point(0.501, 0.523).tap()
        settle(3)
        point(0.503, 0.529).tap()
        settle(2)
        point(0.501, 0.405).tap()
        settle(3)
        point(0.300, 0.290).tap()
        settle(0.5)
        point(0.300, 0.290).tap()
        settle(2)
        let selectedSave = capture("52-valentia-save-selected")
        point(0.755, 0.810).tap()
        settle(8)
        let developedCity = capture("52-valentia-developed-city")
        XCTAssertGreaterThan(
            visualDifference(
                selectedSave,
                developedCity,
                in: CGRect(x: 0.05, y: 0.08, width: 0.90, height: 0.82)
            ),
            0.08,
            "The developed Valentia city did not replace the load dialog"
        )

        for _ in 0..<2 {
            XCUIDevice.shared.press(.home)
            settle(2)
            app.activate()
            XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
            settle(3)
        }

        // Valentia pauses on messages and inspection panels. Periodically
        // dismiss the lower-right close button so the city reaches the later
        // event-video path seen in the device log.
        for _ in 0..<10 {
            settle(5)
            point(0.650, 0.710).tap()
        }
        settle(15)

        capture("52a-valentia-event-video-before-background")
        for _ in 0..<2 {
            XCUIDevice.shared.press(.home)
            settle(2)
            app.activate()
            XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
            settle(5)
        }
        settle(10)
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
        XCTAssertFalse(
            app.staticTexts["Augustus has crashed :("].exists,
            "Valentia crashed after repeated iPad background/foreground transitions"
        )
        capture("52-valentia-after-background-cycles")
    }
}
