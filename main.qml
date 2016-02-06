/*
 * Copyright (C) 2015 - Florent Revest <revestflo@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation, either version 2.1 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import QtQuick.Controls 1.3
import QtFeedback 5.0
import org.asteroid.controls 1.0

Item {
    id: app
    anchors.fill: parent

    ProgressCircle {
        id: circle
        anchors.fill: parent
        _start_angle: -Math.PI*3/2
        _end_angle: Math.PI/2
        property int seconds: 120
        value: seconds/(30*60)

        MouseArea {
            id: mouseArea
            anchors.fill: parent

            onPositionChanged: if(mouseArea.pressed) circle.seconds = mouseArea.valueFromPoint(mouseArea.mouseX, mouseArea.mouseY)*30*60;
            onPressed:                               circle.seconds = mouseArea.valueFromPoint(mouseArea.mouseX, mouseArea.mouseY)*30*60;

            function valueFromPoint(x, y) {
                var yy = circle.height / 2 - y;
                var xx = x - circle.width / 2;

                var angle = (xx || yy) ? Math.atan2(yy, xx) : 0;

                if(angle < -Math.PI / 2)
                    angle += 2 * Math.PI;

                var v = (Math.PI * 4 / 3 - angle) / (Math.PI * 10 / 6);
                return Math.max(0, Math.min(1, v));
            }
        }

        Label {
            anchors.centerIn: parent
            font.pixelSize: 40
            text: zeroPad(Math.floor(circle.seconds/60)) + ":" + zeroPad(Math.floor((circle.seconds%60)))
            function zeroPad(n) {
                return (n < 10 ? "0" : "") + n
            }
        }

        IconButton {
            id: iconButton
            iconName: timer.running ? "pause" : "timer-outline"
            iconColor: "black"
            visible: circle.seconds !== 0

            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: Units.dp(13)
            }

            onClicked: {
                if(timer.running)
                    timer.stop()
                else
                    timer.start()
            }
        }
    }
    
    HapticsEffect {
        id: haptics
        attackIntensity: 0.0
        attackTime: 250
        intensity: 1.0
        duration: 100
        fadeTime: 250
        fadeIntensity: 0.0
    }

    Timer {
        id: timer
        running: false
        repeat: true
        onTriggered: {
            if(circle.seconds == 0)
            {
                timer.stop()
                haptics.start()
                // TODO: wake up screen and vibrate
            }
            else
                circle.seconds = circle.seconds - 1
        }
    }
}
