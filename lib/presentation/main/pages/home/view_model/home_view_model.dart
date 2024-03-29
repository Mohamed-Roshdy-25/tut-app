// ignore_for_file: void_checks

import 'dart:async';
import 'dart:ffi';

import 'package:rxdart/rxdart.dart';
import 'package:tut_app_with_clean_architecture/domain/model/models.dart';
import 'package:tut_app_with_clean_architecture/domain/useCase/home_useCase.dart';
import 'package:tut_app_with_clean_architecture/presentation/base/base_view_model.dart';
import 'package:tut_app_with_clean_architecture/presentation/common/state_renderer/state_renderer.dart';
import 'package:tut_app_with_clean_architecture/presentation/common/state_renderer/state_renderer_impl.dart';

class HomeViewModel extends BaseViewModel
    with HomeViewModelInput, HomeViewModelOutput {
  final _dataStreamController = BehaviorSubject<HomeViewObject>();

  final HomeUseCase _homeUseCase;

  HomeViewModel(this._homeUseCase);

  // --  inputs
  @override
  void start() {
    _getHomeData();
  }

  _getHomeData() async {
    inputState.add(LoadingState(
        stateRendererType: StateRendererType.fullScreenLoadingState));
    (await _homeUseCase.execute(Void)).fold(
            (failure) => {
          // left -> failure
          inputState.add(ErrorState(
              StateRendererType.fullScreenErrorState, failure.message))
        }, (homeObject) {
      // right -> data (success)
      // content
      inputState.add(ContentState());
      inputHomeData.add(HomeViewObject(homeObject.data.stores,
          homeObject.data.services, homeObject.data.banners));
      // navigate to main screen
    });
  }

  @override
  void dispose() {
    _dataStreamController.close();
    super.dispose();
  }

  @override
  Sink get inputHomeData => _dataStreamController.sink;

  // -- outputs
  @override
  Stream<HomeViewObject> get outputHomeData =>
      _dataStreamController.stream.map((data) => data);
}

abstract class HomeViewModelInput {
  Sink get inputHomeData;
}

abstract class HomeViewModelOutput {
  Stream<HomeViewObject> get outputHomeData;
}

class HomeViewObject {
  List<Store> stores;
  List<Service> services;
  List<BannerAd> banners;

  HomeViewObject(this.stores, this.services, this.banners);
}