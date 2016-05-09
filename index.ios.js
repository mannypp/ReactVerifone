/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';

import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  TouchableHighlight,
  NativeModules,
  NativeAppEventEmitter
} from 'react-native';

var verifone = NativeModules.Verifone;
var subscription;

class ReactVerifone extends Component {
  constructor(props) {
    super(props);

    this.state = {
      result: null
    };
  }

  componentWillMount() {
    subscription = NativeAppEventEmitter.addListener('logEvent', (evt) => {
      console.log("Event Received: " + JSON.stringify(evt));
      /*this.setState({
        result: evt.amount ? evt.amount : 1.99
      })*/
    });
  }

  componentWillUnmount() {
    subscription.remove();
  }

  setup() {
    verifone.setup({});
  }

  cancel() {
    verifone.cancelPayment({});
  }

  handler() {
    verifone._acceptPayment({"amount": 3.99, "options": { "solicited": true, "use_alternate_card_entry": true}});
  }

  render() {
    return (
      <View style={styles.container}>
        <TouchableHighlight style={styles.buttonContainer} onPress={this.setup.bind(this)}>
          <View>
            <Text style={styles.buttonText}>Setup</Text>
          </View>
        </TouchableHighlight>
        <TouchableHighlight style={styles.buttonContainer} onPress={this.handler.bind(this)}>
          <View>
            <Text style={styles.buttonText}>Pay!</Text>
          </View>
        </TouchableHighlight>
        <TouchableHighlight style={styles.buttonContainer} onPress={this.cancel.bind(this)}>
          <View>
            <Text style={styles.buttonText}>Cancel</Text>
          </View>
        </TouchableHighlight>
        <Text style={styles.welcome}>
          {this.state.result}
        </Text>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  buttonContainer: {
    flexDirection: 'row',
    paddingTop: 10,
    paddingBottom: 10,
  },
  buttonText: {
  }  
});

AppRegistry.registerComponent('ReactVerifone', () => ReactVerifone);
