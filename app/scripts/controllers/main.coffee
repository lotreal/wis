'use strict'
angular.module('WisApp').controller 'MainCtrl', [
    '$scope', '$http', '$location'
    ($scope, $http, $location) ->
        $scope.username = ''

        $scope.login = ->
            $http.post('/login', {name: $scope.username})
            .success((res)->
                [err, token] = res

                if err
                    console.log err
                    alert(err)
                    return

                $location.path '/1ntlvb7r'
            )
            .error((err)->
                console.log err
            )

        $scope.isSpecificPage = ->
            true


        # for ui
        $scope.isCollapsed = true
        $scope.subtitle = '江南五大才子'

        $scope.start = ->
            $scope.isCollapsed = !$scope.isCollapsed

        $scope.list = [
            {flag: 'master', ready: !false, name: '罗涛', slogan: '银烛荧煌照绮罗，八溟争敢起波涛。'}
            {flag: '',       ready: true,  name: '杨纪珂', slogan: '三阳本是标灵纪，黄道天清拥珮珂。'}
            {flag: 'you',    ready: !false, name: '邓娟', slogan: '邓艾心知战地宽，娟娟西月生蛾眉。'}
            {flag: '',       ready: true,  name: '王九宁', slogan: '九转但能生羽翼，宁知此木超尘埃。'}
        ]

        $scope.speak = [
            {flag: '', name: '罗涛', message: '银烛荧煌照绮罗，八溟争敢起波涛。'}
            {flag: 'turn', name: '杨纪珂', message: '三阳本是标灵纪，黄道天清拥珮珂。'}
            {flag: '', name: '邓娟', message: '邓艾心知战地宽，娟娟西月生蛾眉。'}
            {flag: '', name: '王九宁', message: '九转但能生羽翼，宁知此木超尘埃。'}
        ]

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
