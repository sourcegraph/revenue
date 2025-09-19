plugins {
  alias(libs.plugins.kotlin.jvm)
  alias(libs.plugins.ktor)
}

group = "com.sourcegraph.revenue"

version = "0.0.1"

application { mainClass = "io.ktor.server.netty.EngineMain" }

java {
  toolchain {
    languageVersion = JavaLanguageVersion.of(21)
  }
}

dependencies {
  implementation(libs.ktor.server.core)
  implementation(libs.ktor.server.pebble)
  implementation(libs.ktor.server.content.negotiation)
  implementation(libs.ktor.server.openapi)
  implementation(libs.ktor.server.netty)
  implementation(libs.logback.classic)
  implementation(libs.ktor.server.config.yaml)
  testImplementation(libs.ktor.server.test.host)
  testImplementation(libs.kotlin.test.junit)
}
