import 'package:flutter/material.dart';
import 'package:graphql/client.dart';

class GraphQLService {
  HttpLink _httpLink;
  WebSocketLink _webSocketLink;
  InMemoryStore _store = InMemoryStore();
  GraphQLClient _httpClient;
  GraphQLClient _websocketClient;
  void setupClient(
      {@required String httpLink, @required String webSocketLink}) {
    /*final AuthLink authLink = AuthLink(
      getToken: () => token
    );*/

    _httpLink = HttpLink(
      httpLink,
    );
    _webSocketLink = WebSocketLink(webSocketLink,
        config: SocketClientConfig(
          autoReconnect: true,
          inactivityTimeout: const Duration(minutes: 5),
        ));

    //Link httpLink = authLink.concat(_httpLink);
    //Link webSocketLink = authLink.concat(_webSocketLink);

    _httpClient = GraphQLClient(
      link: _httpLink,
      cache: GraphQLCache(store: _store),
    );
    _websocketClient = GraphQLClient(
      link: _webSocketLink,
      cache: GraphQLCache(store: _store),
    );
  }

  Future<QueryResult> query(String query, {Map<String, dynamic> variables}) {
    return _httpClient
        .query(QueryOptions(document: gql(query), variables: variables));
  }

  Future<QueryResult> mutate(String mutation,
      {Map<String, dynamic> variables}) {
    return _httpClient
        .mutate(MutationOptions(document: gql(mutation), variables: variables));
  }

  Stream<QueryResult> subscribe(String subscription,
      {String operationName, Map<String, dynamic> variables}) {
    var _stream = _websocketClient.subscribe(SubscriptionOptions(
        document: gql(subscription),
        variables: variables,
        operationName: operationName));
    return _stream;
  }
}
