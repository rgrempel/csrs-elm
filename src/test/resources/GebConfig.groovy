import org.openqa.selenium.firefox.FirefoxDriver
import geb.driver.SauceLabsDriverFactory

driver = {
    new FirefoxDriver()
}
 
reportOnTestFailureOnly = true

atCheckWaiting = true

def sauceLabsBrowser = System.getProperty("geb.saucelabs.browser")
if (sauceLabsBrowser) {
    waiting {
        timeout = 10
        retryInterval = 0.5
    }

    driver = {
       def username = System.getenv("GEB_SAUCE_LABS_USER")
       assert username
       def accessKey = System.getenv("GEB_SAUCE_LABS_ACCESS_PASSWORD")
       assert accessKey
       new SauceLabsDriverFactory().create(sauceLabsBrowser, username, accessKey)
    }
}
