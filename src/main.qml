/*
 * Copyright (C) 2023 Lepras <heyabhinav@protonmail.com>
 *               2021 Timo Könnecke <github.com/eLtMosen>
 *               2016 Sylvia van Os <iamsylvie@openmailbox.org>
 *               2015 Florent Revest <revestflo@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import org.asteroid.controls 1.0
import Nemo.Configuration 1.0
import Nemo.Alarms 1.0

Application {
    id: app

    centerColor: "#A6005F"
    outerColor: "#0C0003"

    property var alarmObject: null
    property var startDate: 0
    property int selectedTime: 0
    property int seconds: 5*60

    function availableTimers() {
        return 1; // TODO make this dynamic 
    }

    function zeroPad(n) {
        return (n < 10 ? "0" : "") + n
    }

    // TODO fix layout

    Component {
        id: timerDelegate
    
        Item {
            anchors.fill: parent
            property int timerNb: index

            ConfigurationValue {
                id: lastTimerDuration
                key: "/org/asteroidos/timer/last-timer-duration-" + index // TODO index is int, not string
                defaultValue: 5*60
            }

            AlarmsModel {
                id: alarmModel
                onlyCountdown: true
                onPopulatedChanged: {
                    for (var i=0; rowCount() > i; i++) {
                        // Get Alarm object using AlarmObjectRole(=0x0100) // TODO alarms -> with index
                        var alarm = alarmModel.data(alarmModel.index(i, 0), 0x0100)
                        if (!alarm.enabled) {
                            alarm.deleteAlarm()
                        } else {
                            alarmObject = alarm
                            startDate = new Date
                            seconds = alarm.triggerTime - (startDate.getTime()/1000)
                            selectedTime = seconds
                            timer.start()
                        }
                    }
                }
            }

            IconButton {
                id: addTimer
                iconName: "ios-add"
                onClicked: {
                    // TODO add timer
                }
            }

            Row {
                id: mainRow
                anchors {
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: -parent.height * 0.002
                    left: parent.left
                    leftMargin: Dims.w(15.9)
                    right: parent.right
                    rightMargin: Dims.w(1.6)
                }
                height: Dims.h(70)

                Spinner {
                    id: hourLV
                    currentIndex: lastTimerDuration.value / 3600
                    enabled: !timer.running
                    height: parent.height
                    width: parent.width * 0.16
                    model: 24
                    delegate: SpinnerDelegate { text: zeroPad(index) }
                    onCurrentIndexChanged: if(enabled) seconds = secondLV.currentIndex + 60*minuteLV.currentIndex + 3600*hourLV.currentIndex
                }

                Spinner {
                    id: minuteLV
                    currentIndex: (lastTimerDuration.value % 3600) / 60
                    enabled: !timer.running
                    height: parent.height
                    width: parent.width * 0.505
                    model: 60
                    highlightMoveDuration: currentIndex != 0 ? 400 : 0
                    onCurrentIndexChanged: if(enabled) seconds = secondLV.currentIndex + 60*minuteLV.currentIndex + 3600*hourLV.currentIndex
                }

                Spinner {
                    id: secondLV
                    currentIndex: lastTimerDuration.value % 60
                    enabled: !timer.running
                    height: parent.height
                    width: parent.width * 0.16
                    model: 60
                    highlightMoveDuration: currentIndex != 0 ? 400 : 0
                    onCurrentIndexChanged: if(enabled) seconds = secondLV.currentIndex + 60*minuteLV.currentIndex + 3600*hourLV.currentIndex
                }
            }

            Label {
                text: "h"
                anchors {
                    centerIn: parent
                    verticalCenterOffset: -parent.height * 0.056
                    horizontalCenterOffset: -parent.width * 0.199
                }
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Dims.l(6.4)
                font.styleName: "Medium"
                opacity:0.9
            }

            Label {
                text: "m"
                anchors {
                    centerIn: parent
                    verticalCenterOffset: -parent.height * 0.056
                    horizontalCenterOffset: parent.width * 0.084
                }
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Dims.l(6.4)
                font.styleName: "Medium"
                opacity:0.9
            }

            Label {
                text: "s"
                anchors {
                    centerIn: parent
                    verticalCenterOffset: -parent.height * 0.056
                    horizontalCenterOffset: parent.width * 0.343
                }
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Dims.l(6.4)
                font.styleName: "Medium"
                opacity:0.9
            }

            IconButton {
                id: iconButton
                iconName: timer.running ? "ios-pause" : "ios-timer-outline"
                visible: seconds !== 0
                anchors { 
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                    bottomMargin: Dims.iconButtonMargin
                }

                onClicked: {
                    if (alarmObject !== null) {
                        alarmObject.deleteAlarm()
                        timer.stop()
                    } else {
                        alarmObject = alarmModel.createAlarm()
                        alarmObject.countdown = true
                        alarmObject.second = seconds-1
                        alarmObject.title = "";
                        alarmObject.enabled = true
                        alarmObject.save()

                        startDate = new Date
                        lastTimerDuration.value = selectedTime = seconds
                        timer.start()
                    }
                }
            }

            Timer {
                id: timer
                running: false
                repeat: true
                interval: 500
                triggeredOnStart: true
                onTriggered: {
                    if(seconds <= 0) {
                        timer.stop()
                    } else {
                        var currentDate = new Date
                        seconds = selectedTime - (currentDate.getTime() - startDate.getTime())/1000
                        secondLV.currentIndex = seconds%60
                        minuteLV.currentIndex = (seconds%3600)/60
                        hourLV.currentIndex = seconds/3600
                    }
                }
            }
        }
    }    

    ListView {
        id: lv

        anchors.fill:parent
        model: availableTimers()
        delegate: timerDelegate
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        highlightRangeMode: ListView.StrictlyEnforceRange
    }

    PageDot {
        height: Dims.h(3)
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: Dims.h(3.8)
        }
        currentIndex: lv.currentIndex
        dotNumber: availableTimers()
    }
}
