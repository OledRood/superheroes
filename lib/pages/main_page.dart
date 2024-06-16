import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:superheroes/pages/superhero_page.dart';
import 'package:superheroes/resources/superherous_image.dart';
import 'package:superheroes/widgets/action_botton.dart';
import 'package:superheroes/widgets/info_with_bottom.dart';
import 'package:superheroes/widgets/superhero_card.dart';

import '../blocs/main_bloc.dart';
import '../resources/superheroes_colors.dart';

import 'package:http/http.dart' as http;

class MainPage extends StatefulWidget {
  final http.Client? client;

  MainPage({super.key, this.client});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late MainBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = MainBloc(client: widget.client);
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: SuperheroesColors.background,
        body: SafeArea(child: MainPageContent()),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}

class MainPageContent extends StatefulWidget {
  @override
  State<MainPageContent> createState() => _MainPageContentState();
}

class _MainPageContentState extends State<MainPageContent> {
  late FocusNode searchFieldFocusNode;

  @override
  void initState() {
    super.initState();
    searchFieldFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    //возвращает первый созданный объект в MainPageState, затем забираем от туда блок
    // final _MainPageState state =
    //     context.findAncestorStateOfType<_MainPageState>()!;
    // final MainBloc bloc = state.bloc;

    return Stack(
      children: [
        MainPageStateWidget(
          searchFieldFocusNode: searchFieldFocusNode,
        ),
        Padding(
          padding: EdgeInsets.only(top: 12, left: 16, right: 16),
          child: SearchWidget(
            searchFieldFocusNode: searchFieldFocusNode,
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    searchFieldFocusNode.dispose();
    super.dispose();
  }
}

class SearchWidget extends StatefulWidget {
  final FocusNode searchFieldFocusNode;

  const SearchWidget({super.key, required this.searchFieldFocusNode});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController controller = TextEditingController();
  bool haveSearchText = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
      final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);
      controller.addListener(() {
        bloc.updateText(controller.text);
        final haveText = controller.text.isNotEmpty;
        if (haveSearchText != haveText) {
          setState(() {
            haveSearchText = haveText;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);
    return TextField(
      focusNode: widget.searchFieldFocusNode,
      //Изменения значения ввода
      textInputAction: TextInputAction.search,
      // Вссе слова будут с большой букву
      textCapitalization: TextCapitalization.words,
      cursorColor: Colors.white,
      controller: controller,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white, width: 2)),
        filled: true,
        fillColor: SuperheroesColors.indigo75,
        isDense: true,
        prefixIcon: Icon(
          Icons.search,
          size: 24,
          color: Colors.white54,
        ),
        suffix: GestureDetector(
            onTap: () {
              controller.clear();
            },
            child: Icon(
              Icons.clear,
              color: Colors.white,
            )),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: haveSearchText
              ? BorderSide(color: Colors.white, width: 2)
              : BorderSide(color: Colors.white24),
        ),
      ),
      style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 20,
          color: SuperheroesColors.text),
    );
  }
}

class MainPageStateWidget extends StatelessWidget {
  final FocusNode searchFieldFocusNode;

  const MainPageStateWidget({super.key, required this.searchFieldFocusNode});

  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);

    return StreamBuilder<MainPageState>(
      stream: bloc.observeMainPageState(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return SizedBox();
        }
        final MainPageState state = snapshot.data!;
        switch (state) {
          case MainPageState.loading:
            return LoadingIndicator();
          case MainPageState.minSymbols:
            return MinSymbolsWidget();
          case MainPageState.noFavorites:
            return NoFavoritesWidget(
                searchFieldFocusNode: searchFieldFocusNode);
          case MainPageState.favorites:
            return SuperheroesList(
                title: "Your favorites",
                stream: bloc.observeFavoritesSuperheroes());
          case MainPageState.searchResults:
            return SuperheroesList(
                title: "Search results",
                stream: bloc.observeSearchSuperheroes());
          case MainPageState.nothingFound:
            return NothingFoundWidget(
              searchFieldFocusNode: searchFieldFocusNode,
            );
          case MainPageState.loadingError:
            return LoadingErrorWidget();
          default:
            return Center(
                child: Text(
              snapshot.data!.toString(),
              style: TextStyle(color: SuperheroesColors.text),
            ));
        }
      },
    );
  }
}

class LoadingErrorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    return Center(
        child: InfoWithButton(
      title: 'Error happened',
      subtitle: 'Please, try again',
      buttonText: 'Retry',
      assetImage: SuperheroesImage.supermen,
      imageHeight: 106,
      imageWidth: 126,
      imageTopPadding: 22,
      onTap: bloc.retry,
    ));
  }
}

class NothingFoundWidget extends StatelessWidget {
  final FocusNode searchFieldFocusNode;

  const NothingFoundWidget({super.key, required this.searchFieldFocusNode});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: InfoWithButton(
      title: 'Nothin found',
      subtitle: 'Search for something else',
      buttonText: 'Search',
      assetImage: SuperheroesImage.hulk,
      imageHeight: 112,
      imageWidth: 84,
      imageTopPadding: 16,
      onTap: () => searchFieldFocusNode.requestFocus(),
    ));
  }
}

class NoFavoritesWidget extends StatelessWidget {
  final FocusNode searchFieldFocusNode;

  const NoFavoritesWidget({super.key, required this.searchFieldFocusNode});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: InfoWithButton(
      title: 'No favorites yet',
      subtitle: 'Search and add',
      buttonText: 'Search',
      assetImage: SuperheroesImage.ironmen,
      imageHeight: 119,
      imageWidth: 108,
      imageTopPadding: 9,
      onTap: () => searchFieldFocusNode.requestFocus(),
    ));
  }
}

class MinSymbolsWidget extends StatelessWidget {
  const MinSymbolsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
          padding: EdgeInsets.only(top: 110),
          child: Text(
            'Enter at leaest minimum 3 simbols',
            style: TextStyle(
              color: SuperheroesColors.text,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          )),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 110),
        child: CircularProgressIndicator(
          color: SuperheroesColors.blue,
          strokeWidth: 4,
        ),
      ),
    );
  }
}

class SuperheroesList extends StatelessWidget {
  final String title;
  final Stream<List<SuperheroInfo>> stream;

  const SuperheroesList({super.key, required this.title, required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SuperheroInfo>>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox.shrink();
          }
          final List<SuperheroInfo> superheroes = snapshot.data!;
          return ListView.separated(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: (superheroes.length + 1),
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return ListTitleWidget(title: title);
              }
              final SuperheroInfo item = superheroes[index - 1];
              return ListTile(superhero: item);
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(
                height: 8,
              );
            },
          );
        });
  }
}

class ListTile extends StatelessWidget {

  final SuperheroInfo superhero;

  const ListTile({
    super.key,
    required this.superhero,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Dismissible(
        key: ValueKey(superhero),
        child: SuperheroCard(
          superheroInfo: superhero,
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SuperheroPage(id: superhero.id)));
          },
        ),
        background: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: SuperheroesColors.red),
          height: 70,
          alignment: Alignment.center,
          child: Text(
            'Remove from favorites'.toUpperCase(),
            style: TextStyle(
                fontSize: 12,
                color: SuperheroesColors.text,
                fontWeight: FontWeight.w700),
          ),
        ),
        onDismissed: (_) => bloc.removeFromFavorites(superhero.id),

      ),
    );
  }
}

class ListTitleWidget extends StatelessWidget {
  final String title;
  const ListTitleWidget({
    super.key, required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 90, bottom: 12),
      child: Text(title,
          style: TextStyle(
              color: SuperheroesColors.text,
              fontSize: 24,
              fontWeight: FontWeight.w800)),
    );
  }
}
