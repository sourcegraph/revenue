package com.sourcegraph.revenue

import io.ktor.server.application.*
import io.ktor.server.pebble.*
import io.ktor.server.plugins.openapi.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.pebbletemplates.pebble.loader.ClasspathLoader
import io.pebbletemplates.pebble.loader.FileLoader
import java.io.File

fun Application.configureTemplating() {
    install(Pebble) {
        loader(if (this@configureTemplating.developmentMode) {
            // In development mode, use FileLoader for hot reload
            FileLoader().apply {
                prefix = File("src/main/resources/templates").absolutePath
            }
        } else {
            // In production, use ClasspathLoader for better performance
            ClasspathLoader().apply {
                prefix = "templates"
            }
        })
    }
}
