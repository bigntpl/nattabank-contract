import React from "react";
import App from "../../pages/index";

const NavBar  = (): JSX.Element => {
  return (
    <>
      <div className="flex flex-row justify-around items-center bg-amber-200 px-10 py-4">
        <span className="text-3xl font-bold">NattaBank</span>
        <App />
      </div>
    </>
  );
}

export default NavBar