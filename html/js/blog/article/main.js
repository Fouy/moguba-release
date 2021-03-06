/*!
 * Copyright 2017 xuefeihu
 * Licensed under the Themeforest Standard Licenses
 */

(function() {
    // 初始化表格
    $('#exampleTableEvents').bootstrapTable({
        method: 'get',
        toolbar: '#exampleTableEventsToolbar',    //工具按钮用哪个容器
        striped: true,      //是否显示行间隔色
        cache: false,      //是否使用缓存，默认为true，所以一般情况下需要设置一下这个属性（*）
        pagination: true,
        sortable: false,
        sortOrder: "asc",
        pageNumber:1,      //初始化加载第一页，默认第一页
        pageSize: 10,      //每页的记录行数（*）
        pageList: [10, 25, 50, 100],  //可供选择的每页的行数（*）
        url: "/article/list",
        queryParamsType:'', //默认值为 'limit' ,在默认情况下 传给服务端的参数为：offset,limit,sort
                            // 设置为 ''  在这种情况下传给服务器的参数为：pageSize,pageNumber
        //queryParams: queryParams,//前端调用服务时，会默认传递上边提到的参数，如果需要添加自定义参数，可以自定义一个函数返回请求参数
        sidePagination: "server",   //分页方式：client客户端分页，server服务端分页（*）
        strictSearch: true,
        //showColumns: true,     //是否显示所有的列
        //showRefresh: true,     //是否显示刷新按钮
        minimumCountColumns: 2,    //最少允许的列数
        clickToSelect: true,    //是否启用点击选中行
        searchOnEnterKey: true,
        columns: [{
            field: 'type_name',
            title: '分类',
            align: 'center'
        }, {
            field: 'tag_name',
            title: '标签',
            align: 'center'
        }, {
            field: 'title',
            title: '文章标题',
            align: 'center'
        }, {
            field: 'source',
            title: '信息来源',
            align: 'center'
        }, {
            field: 'view_count',
            title: '查看人数',
            align: 'center'
        }, {
            field: 'comment_count',
            title: '评论数',
            align: 'center'
        }, {
            field: 'hot_name',
            title: '热门',
            align: 'center'
        }, {
            field: 'create_time',
            title: '创建时间',
            align: 'center'
        }, {
            field: 'modify_time',
            title: '更新时间',
            align: 'center'
        }, {
            field: 'article_id',
            title: '操作',
            align: 'center',
            formatter:function(value, row, index){
                //value：当前field的值，即article_id
                //row：当前行的数据
                var a = '<button class="btn btn-info" type="button" onclick=editArticleWin('+value+')><i class="fa fa-paste"></i> 编辑</button>';
                a = a + '<br/><button class="btn btn-warning" type="button" onclick=deleteWin('+value+')><i class="glyphicon glyphicon-trash"></i> <span class="bold">删除</span></button>';
                return a;
            } 
        }]
    });

    // 初始化type
    var type = $("#type");
    type.empty();
    $.post("/articletype/list", {}, function(result){
        var data = eval(result);
        var list = data.data;

        var opt = $('<option></option>');
        opt.attr('value', '');
        opt.append('--全部--');
        opt.appendTo(type);
        for(var i = 0; i < list.length; i++) {
            var opt = $('<option></option>');
            opt.attr('value', list[i].type_id);
            opt.append(list[i].name);
            opt.appendTo(type);
        }
    }, 'json');

})();

// 新增窗口
function addArticleWin(){
  //页面层
    parent.layer.open({
        type: 2,
        title: '新增文章',
        skin: 'layui-layer-rim', //加上边框
        area: ['1000px', '700px'], //宽高
        content: '/blog/article/add.html',
        end: function () {
            search();
        }
    });
}

// 编辑窗口
function editArticleWin(article_id){
    parent.layer.open({
        type: 2,
        title: '编辑文章',
        skin: 'layui-layer-rim', //加上边框
        area: ['1000px', '700px'], //宽高
        content: '/blog/article/edit.html?articleId='+article_id,
        end: function () {
            search();
        }
    });
}

// 搜索
function search(){
    var param = {};
    param.typeId = $('#type').val();
    param.hot = $('#hot').val();
    param.keyword = $('#title').val();
    $('#exampleTableEvents').bootstrapTable('refresh',{query : param});
}

// 删除
function deleteWin(article_id){
    swal({
        title: "您确定要删除这条信息吗",
        text: "删除后将无法恢复，请谨慎操作！",
        type: "warning",
        showCancelButton: true,
        confirmButtonColor: "#DD6B55",
        confirmButtonText: "是的，我要删除！",
        cancelButtonText: "让我再考虑一下…",
        closeOnConfirm: false,
        closeOnCancel: true
    },
    function (isConfirm) {
        if (isConfirm){
            $.post("/article/delete", {articleId : article_id}, function(result){
                if(result.success) {
                    swal("删除成功！", result.msg, "success");
                }else {
                    swal("删除失败！", result.msg, "error");
                }
                search();
            }, 'json');
        }
    });

}
