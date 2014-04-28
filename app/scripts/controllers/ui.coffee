"use strict"
app.controller "UiCtrl", [
    "$scope"
    "socket"
    ($scope, socket) ->
        socket.on "news", (data) ->
            console.log data
            socket.emit "my other event",
                my: "data"

            return

        socket.emit "echo",
            msg: "nihao"

        socket.on "echo", (msg) ->
            console.log msg
            return

        $scope.awesomeThings = [
            "HTML5 Boilerplate"
            "AngularJS"
            "Karma"
        ]
        $scope.oneAtATime = true
        $scope.groups = [
            {
                title: "Dynamic Group Header - 1"
                content: "Dynamic Group Body - 1"
            }
            {
                title: "Dynamic Group Header - 2"
                content: "Dynamic Group Body - 2"
            }
        ]
        $scope.items = [
            "Item 1"
            "Item 2"
            "Item 3"
        ]
        $scope.addItem = ->
            newItemNo = $scope.items.length + 1
            $scope.items.push "Item " + newItemNo
            return

        
        # alert
        $scope.alerts = [
            {
                type: "danger"
                msg: "Oh snap! Change a few things up and try submitting again."
            }
            {
                type: "success"
                msg: "Well done! You successfully read this important alert message."
            }
        ]
        $scope.addAlert = ->
            $scope.alerts.push msg: "Another alert!"
            return

        $scope.closeAlert = (index) ->
            $scope.alerts.splice index, 1
            return

        
        # button
        $scope.singleModel = 1
        $scope.radioModel = "Middle"
        $scope.checkModel =
            left: false
            middle: true
            right: false
]
