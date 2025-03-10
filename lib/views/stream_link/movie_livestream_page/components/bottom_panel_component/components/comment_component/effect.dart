import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:movie/actions/api/base_api.dart';
import 'package:movie/globalbasestate/store.dart';
import 'package:movie/models/base_api_model/base_user.dart';
import 'package:movie/models/models.dart';
import 'package:toast/toast.dart';
import 'action.dart';
import 'state.dart';

Effect<CommentState> buildEffect() {
  return combineEffects(<Object, Effect<CommentState>>{
    CommentAction.action: _onAction,
    CommentAction.addComment: _addComment,
    Lifecycle.initState: _onInit,
    Lifecycle.dispose: _onDispose,
  });
}

void _onAction(Action action, Context<CommentState> ctx) {}

void _onInit(Action action, Context<CommentState> ctx) {
  ctx.state.scrollController = ScrollController()
    ..addListener(() {
      if (ctx.state.scrollController.position.pixels ==
          ctx.state.scrollController.position.maxScrollExtent) {
        _loadMore(action, ctx);
      }
    });
  ctx.state.isBusy = false;
}

void _onDispose(Action action, Context<CommentState> ctx) {
  ctx.state.scrollController?.dispose();
}

void _addComment(Action action, Context<CommentState> ctx) async {
  final String _commentTxt = action.payload;
  final _user = GlobalStore.store.getState().user;
  if (_user == null) {
    Toast.show('login before comment', duration: 2);
    return;
  }
  if (_commentTxt != '' && _commentTxt != null) {
    final String _date = DateTime.now().toString();
    final _baseApi = BaseApi.instance;
    final MovieComment _comment = MovieComment.fromParams(
        mediaId: ctx.state.movieId,
        comment: _commentTxt,
        uid: _user.firebaseUser.uid,
        updateTime: _date,
        createTime: _date,
        u: BaseUser.fromParams(
            uid: _user.firebaseUser.uid,
            userName: _user.firebaseUser.displayName,
            photoUrl: _user.firebaseUser.photoURL),
        like: 0);
    ctx.dispatch(CommentActionCreator.insertComment(_comment));
    _baseApi.createMovieComment(_comment).then((r) {
      if (r.success) _comment.id = r.result.id;
    });
  }
}

void _loadMore(Action action, Context<CommentState> ctx) async {
  if (!ctx.state.isBusy) {
    ctx.state.isBusy = true;
    final _baseApi = BaseApi.instance;
    final _comment = await _baseApi.getMovieComments(ctx.state.movieId,
        page: ctx.state.comments.page + 1);
    if (_comment.success) {
      if (_comment.result.data.length > 0)
        ctx.dispatch(CommentActionCreator.loadMore(_comment.result));
    }

    ctx.state.isBusy = false;
  }
}
