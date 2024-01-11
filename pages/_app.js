import '@/styles/globals.css';

import { TrackingProvider } from "../conetxt/Tracking";
import {NavBar, Footer} from "../Components";

export default function App({ Component, pageProps }) {
  return (
    <>
    <TrackingProvider>
      <NavBar />
      <Component {...pageProps} />
      <Footer />
    </TrackingProvider>
    </>
  );
}
