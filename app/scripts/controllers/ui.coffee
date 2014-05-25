'use strict'

angular.module('WisApp').controller 'UiCtrl', [
    '$scope', '$http', '$location'
    ($scope, $http, $location) ->
        $scope.isVisible = -> true
        $scope.getBoard = -> '江南四大才子'

        members = [
            {flag: 'master', name: '罗涛', slogan: '银烛荧煌照绮罗，八溟争敢起波涛。'}
            {flag: 'ready',  name: '杨纪珂', slogan: '三阳本是标灵纪，黄道天清拥珮珂。'}
            {flag: '',       name: '邓娟', slogan: '邓艾心知战地宽，娟娟西月生蛾眉。'}
            {flag: 'ready',  name: '王九宁', slogan: '九转但能生羽翼，宁知此木超尘埃。'}
        ]

        speaks = [
            {uid: 'xxx1', profile:{name:'罗涛'}, message: 'Hello, World!'}
            {uid: 'xxx2', profile:{name:'杨纪珂'}, message: ''}
            {uid: 'xxx3', profile:{name:'邓娟'}, message: ''}
            {uid: 'xxx4', profile:{name:'王九宁'}, message: '***'}
        ]

        $scope.model =
            room:
                name: '康熙字典'
            actionLabel: '开始'
            members: members
            word: '卧底'
            round: 1
            scene:
                speaks: speaks
                next: 'xxx2'

        return
]
