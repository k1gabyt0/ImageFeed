import XCTest

final class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()

    // MARK: - Здесь нужно добавить свои креды
    private let email = ""
    private let password = ""
    // MARK: -

    override func setUpWithError() throws {
        continueAfterFailure = false

        app.launch()
    }

    func testAuth() throws {
        // Тыкаем кнопку "Войти"
        app.buttons["Authenticate"].tap()

        // Убеждаемся что открывается WebView
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        // Вводим логин
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText(email)
        loginTextField.swipeUp()

        // Вводим пароль
        let passwordTextField = webView.descendants(matching: .secureTextField)
            .element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        passwordTextField.typeText(password)
        passwordTextField.swipeUp()

        // Тыкаем кнопку Login
        webView.descendants(matching: .button)["Login"].tap()

        // Убеждаемся что появляется таблица и там что-то есть
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }

    func testFeed() throws {
        // Видим список картинок
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        
        // Лайкаем и дизлайкаем картинку
        let likeButton = cell.buttons["LikeButton"]
        likeButton.tap()
        XCTAssertTrue(
            likeButton.wait(
                for: \.isHittable,
                toEqual: true,
                timeout: 3
            )
        )
        likeButton.tap()
        XCTAssertTrue(
            cell.wait(
                for: \.isHittable,
                toEqual: true,
                timeout: 3
            )
        )

        // Свайпаем
        cell.swipeUp()

        // Ждем пока появится картинка которую мы лайкнем
        let cellToOpenAsFullscreen = tablesQuery.children(matching: .cell).element(
            boundBy: 1
        )
        XCTAssertTrue(cellToOpenAsFullscreen.waitForExistence(timeout: 3))

        // Открываем картинку на весь экран
        cellToOpenAsFullscreen.tap()
        let fullscreenImage = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(fullscreenImage.waitForExistence(timeout: 3))
        // Zoom in
        fullscreenImage.pinch(withScale: 3, velocity: 2)
        // Zoom out
        fullscreenImage.pinch(withScale: 0.5, velocity: -2)

        // Возвращаемся назад
        let backButton = app.buttons["BackButton"]
        backButton.tap()

        // Убеждаемся что вернулись к списку картинок
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }

    func testProfile() throws {
        // Видим список картинок
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))

        // Тыкаем на вкладку профиля
        app.tabBars.buttons.element(boundBy: 1).tap()
        // Убеждаемся что он отображается
        XCTAssertTrue(app.images["ProfileImage"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.staticTexts["NameLabel"].waitForExistence(timeout: 1))
        XCTAssertTrue(
            app.staticTexts["NicknameLabel"].waitForExistence(timeout: 1)
        )

        // Тыкаем кнопку логаута
        app.buttons["LogoutButton"].tap()
        // Видим алерт и подтверждаем
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()

        // Мы вернулись на страницу логина
        XCTAssertTrue(app.buttons["Authenticate"].waitForExistence(timeout: 3))
    }
}
