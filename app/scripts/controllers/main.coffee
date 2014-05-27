'use strict'
angular.module('WisApp').controller 'MainCtrl', [
    '$scope', '$http', '$location'
    ($scope, $http, $location) ->
        $scope.submit = ->
            return if $scope.login_form.$error.required

            $http.post('/login', $scope.login)
            .success((res)->
                [err, token] = res

                if err
                    $scope.login_form.$setValidity 'login', false
                    return

                $location.path '/1ntlvb7r'
            )
            .error((err)->
                $scope.login_form.$setValidity 'server', false
                console.log err
            )

        $scope.logout = ->
            $http.get('/logout')
            .success((res)->
                [err, signin] = res

                if err
                    console.log err
                    alert(err)
                    return

                $location.path signin
            )

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
