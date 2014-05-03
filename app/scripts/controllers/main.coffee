'use strict'
angular.module('WisApp').controller 'MainCtrl', [
    '$scope', '$http', '$location'
    ($scope, $http, $location) ->
        $scope.username = '罗涛'

        $scope.login = ->
            $http.post('/login', {name: $scope.username})
            .success((res)->
                [err, token] = res

                if err
                    console.log err
                    alert(err)
                    return

                $location.path '/wis'
            )
            .error((err)->
                console.log err
            )

        $scope.isSpecificPage = ->
            true
        return
]

angular.module('WisApp').controller 'ModalDemoCtrl', [
    '$scope', '$modal', '$log'
    ($scope, $modal, $log) ->
        ModalInstanceCtrl = ($scope, $modalInstance, items) ->
            $scope.items = items
            $scope.selected = item: $scope.items[0]
            $scope.ok = ->
                $modalInstance.close $scope.selected.item
                return

            $scope.cancel = ->
                $modalInstance.dismiss "cancel"
                return

            return

        $scope.items = [
            "item1"
            "item2"
            "item3"
        ]
        $scope.open = (size) ->
            modalInstance = $modal.open(
                templateUrl: "myModalContent.html"
                controller: ModalInstanceCtrl
                size: size
                resolve:
                    items: ->
                        $scope.items
            )
            modalInstance.result.then ((selectedItem) ->
                $scope.selected = selectedItem
                return
            ), ->
                $log.info "Modal dismissed at: " + new Date()
                return

            return

        return
]
