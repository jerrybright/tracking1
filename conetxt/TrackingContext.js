import React, { useState, useEffect } from "react";
import Web3Modal from "web3modal";
import { ethers } from "ethers";
import tracking from "../conetxt/Tracking.json";  // Assuming your context folder is named 'context'

const ContractAddress = "0x4FBEc1f7A88DeFD346A3fF08AD22E47C97687fFb";
const ContractABI = tracking.abi;

const fetchContract = (signerOrProvider) => new ethers.Contract(ContractAddress, ContractABI, signerOrProvider);

export const TrackingContext = React.createContext();

export const TrackingProvider = ({ children }) => {
  const DappName = "Product Tracking Dapp";
  const [currentUser, setCurrentUser] = useState("");

  const createShipment = async (items) => {
    console.log(items);
    const { receiver, pickupTime, distance, price } = items;

    try {
      const web3Modal = new Web3Modal();
      const connection = await web3Modal.connect();
      const provider = new ethers.providers.Web3Provider(connection);
      const signer = provider.getSigner();
      const contract = fetchContract(signer);
      const createItem = await contract.createShipment(
        receiver,
        new Date(pickupTime).getTime(),
        distance,
        ethers.utils.parseUnits(price, 18),
        {
          value: ethers.utils.parseUnits(price, 18),
        }
      );
      await createItem.wait();
      console.log(createItem);
    } catch (error) {
      console.log("Something went wrong", error);
    }
  };

  // Add other functions...

  // Wallet connected
  const checkIfWalletConnected = async () => {
    try {
      if (!window.ethereum) return "Install MetaMask";

      const accounts = await window.ethereum.request({
        method: "eth_accounts",
      });

      if (accounts.length) {
        setCurrentUser(accounts[0]);
      } else {
        return "No account";
      }
    } catch (error) {
      return "Not connected";
    }
  };

  // Connect wallet function
  const connectWallet = async () => {
    try {
      if (!window.ethereum) return "Install MetaMask";
      const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
      setCurrentUser(accounts[0]);
    } catch (error) {
      return "Something went wrong";
    }
  };

  useEffect(() => {
    checkIfWalletConnected();
  }, []);

  return (
    <TrackingContext.Provider
      value={{
        connectWallet,
        createShipment,
        // Add other functions...
        DappName,
        currentUser,
      }}
    >
      {children}
    </TrackingContext.Provider>
  );
};
