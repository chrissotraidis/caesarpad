import UIKit
import XCTest

final class CaesarPadUITests: XCTestCase {
    private let app = XCUIApplication(bundleIdentifier: "com.github.keriew.augustus")

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

        point(0.501, 0.380).tap()
        settle()
        point(0.681, 0.748).tap()
        settle(2)
        capture("03-mission-briefing")

        point(0.673, 0.853).tap()
        settle(4)
        point(0.610, 0.565).tap()
        settle(2)
        let mission = capture("04-mission-started")

        point(0.895, 0.375).tap()
        settle()
        let selected = capture("05-tap-selected-housing")
        let selectionDifference = visualDifference(
            mission,
            selected,
            in: CGRect(x: 0.82, y: 0.18, width: 0.17, height: 0.45)
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
            (0.820, 0.055),
            (0.835, 0.055),
            (0.850, 0.055),
            (0.820, 0.070),
            (0.835, 0.070),
            (0.850, 0.070),
            (0.820, 0.085),
            (0.835, 0.085),
            (0.850, 0.085),
        ]
        var cancelDifference = 0.0
        for candidate in cancelCandidates {
            point(candidate.0, candidate.1).tap()
            settle(0.25)
            let afterCandidate = XCUIScreen.main.screenshot()
            cancelDifference = visualDifference(
                cancelBefore,
                afterCandidate,
                in: CGRect(x: 0.79, y: 0.01, width: 0.09, height: 0.12)
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
        point(0.903, 0.615).tap()
        settle()
        let speedAfter = capture("10-speed-changed")
        let speedDifference = visualDifference(
            speedBefore,
            speedAfter,
            in: CGRect(x: 0.83, y: 0.54, width: 0.16, height: 0.12)
        )
        XCTAssertGreaterThan(speedDifference, 0.0005, "Game speed was not reachable by touch")

        point(0.970, 0.615).tap()
        settle(0.5)
        let pauseStart = capture("11-paused")
        let pauseBannerDifference = visualDifference(
            speedAfter,
            pauseStart,
            in: CGRect(x: 0.23, y: 0.02, width: 0.45, height: 0.15)
        )
        XCTAssertGreaterThan(pauseBannerDifference, 0.01, "Pause banner did not appear")
        settle(3)
        let pauseHeld = capture("12-pause-held")
        let clockDifference = visualDifference(
            pauseStart,
            pauseHeld,
            in: CGRect(x: 0.54, y: 0.0, width: 0.20, height: 0.06)
        )
        XCTAssertLessThan(clockDifference, 0.01, "Game clock changed after tapping pause")
    }

    func testMinimalTouchControls() {
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15))
        XCTAssertGreaterThan(app.frame.width, app.frame.height)
        let nativePause = app.buttons["caesarpad.pause"]
        XCTAssertTrue(nativePause.waitForExistence(timeout: 5))
        XCTAssertTrue(nativePause.isHittable)
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
        point(0.501, 0.380).tap()
        settle()
        point(0.681, 0.748).tap()
        settle(2)
        point(0.673, 0.853).tap()
        settle(4)
        point(0.610, 0.565).tap()
        settle(2)
        let mission = capture("21-touch-mission")

        point(0.895, 0.375).tap()
        settle()
        let tapSelected = capture("22-tap-selected")
        XCTAssertGreaterThan(
            visualDifference(
                mission,
                tapSelected,
                in: CGRect(x: 0.82, y: 0.18, width: 0.17, height: 0.45)
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
                in: CGRect(x: 0.79, y: 0.01, width: 0.09, height: 0.12)
            ),
            0.02,
            "Two-finger tap did not map to alternate right-click tool cancel"
        )
        capture("25-two-finger-right-click-complete")

        point(0.895, 0.375).tap()
        settle()
        let longPressBefore = capture("25a-long-press-before")
        point(0.450, 0.420).press(forDuration: 0.8)
        settle()
        let longPressAfter = capture("25b-long-press-right-click")
        XCTAssertGreaterThan(
            visualDifference(
                longPressBefore,
                longPressAfter,
                in: CGRect(x: 0.79, y: 0.01, width: 0.09, height: 0.12)
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

        capture("30-native-pause-before")
        XCTAssertEqual(nativePause.value as? String, "Running")
        nativePause.tap()
        settle()
        let pauseStart = capture("31-native-pause-after")
        XCTAssertEqual(nativePause.value as? String, "Paused")
        settle(3)
        let pauseHeld = capture("31a-native-pause-held")
        XCTAssertLessThan(
            visualDifference(
                pauseStart,
                pauseHeld,
                in: CGRect(x: 0.54, y: 0.0, width: 0.20, height: 0.06)
            ),
            0.01,
            "Game clock changed after tapping the native pause control"
        )
        nativePause.tap()
        settle()
        capture("32-native-resume-after")
        XCTAssertEqual(nativePause.value as? String, "Running")
    }

    func testPrepareLifecycleMission() {
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15))
        point(0.527, 0.453).tap()
        settle(0.5)
        point(0.501, 0.523).tap()
        settle(3)
        point(0.503, 0.529).tap()
        settle(2)
        point(0.501, 0.380).tap()
        settle()
        point(0.681, 0.748).tap()
        settle(2)
        point(0.673, 0.853).tap()
        settle(4)
        point(0.610, 0.565).tap()
        settle(2)

        XCTAssertTrue(app.buttons["caesarpad.pause"].exists)
        capture("40-lifecycle-city-ready")
    }

    func testVerifyLifecycleResume() {
        app.activate()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15))
        let nativePause = app.buttons["caesarpad.pause"]
        XCTAssertTrue(nativePause.waitForExistence(timeout: 5))
        XCTAssertEqual(nativePause.value as? String, "Running, lifecycle autosave resumed")
        capture("41-lifecycle-city-resumed")
    }
}
