import 'dart:convert';

import 'package:buscador_de_giff/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final urlMelhoresGifs =
      "https://api.giphy.com/v1/stickers/trending?api_key=0qgnHN2C6yaklICtyd3jvvcjJt5QH5KE&limit=25&rating=g";

  String _search;
  int _offSet = 0;

  Future<Map> _getSearchGifs() async {
    http.Response response;

    if (_search == null)
      response = await http.get(urlMelhoresGifs);
    else
      response = await http.get(
          "https://api.giphy.com/v1/stickers/search?api_key=0qgnHN2C6yaklICtyd3jvvcjJt5QH5KE&q=$_search&limit=19&offset=$_offSet&rating=g&lang=en");
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(

        backgroundColor: Colors.black,

        title: Image.network(//pegando uma imagen da internet pelo link abaixo
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
      ),

      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 10.0),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                  labelText: 'Pesquisa Aqui!',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.white, width: 0.0),
                  ),
                  border: const OutlineInputBorder()),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _offSet = 0;
                });
              },
            ),
            Expanded(
              child: FutureBuilder(
                //Criando a future pra carregar os gifs
                future: _getSearchGifs(),
                builder: (conetext, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200.0,
                        height: 200.0,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5.0,
                        ),
                      );
                    default:
                      if (snapshot.hasError)
                        return Container();
                      else
                        return _createGitTable(context, snapshot);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createGitTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: _getCount(snapshot.data["data"]),
      itemBuilder: (context, index) {
        if (_search == null || index < snapshot.data["data"].length)
          return GestureDetector(
            //capaz de clincar em uma imagen

            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data["data"][index]["images"]["fixed_height"]
                  ["url"],
              height: 300.0,
              fit: BoxFit.cover,
            ),
  
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) {
                return GifPage(snapshot.data["data"][index]);
              }));
            },
            onLongPress: () {
              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]
                  ["url"]);
            },
          );
        else
          return Container(
            child: GestureDetector(
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 70.0,
                  ),
                  Text(
                    'Carregar mais..',
                    style: TextStyle(color: Colors.white, fontSize: 22.0),
                  )
                ],
              ),
              onTap: () {
                setState(() {
                  _offSet += 19;
                });
              },
            ),
          );
      },
    );
  }

  int _getCount(List data) {
   if(_search == null || _search.isEmpty) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }
}
