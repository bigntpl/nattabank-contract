import App from 'next/app'
import Head from 'next/head'
import NavBar from "../components/navbar/NavBar";
import AccountInfo from "../components/account/AccountInfo";

import '../components/styles/globals.css';

export default class Root extends App {
  render() {
    const { Component, } = this.props

    return (
      <>
        <Head>
          <title>NattaBank</title>
        </Head>
        <NavBar />
        <AccountInfo />
        {/* <Component /> */}
      </>
    )
  }
}
