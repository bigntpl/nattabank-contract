const AccountInfo = (): JSX.Element => {
  return (
    <>
      <div className="flex flex-col container border border-collapse h-96 mx-auto justify-between bg-amber-100 p-4 mt-4">
        <div className="border border-collapse p-4">
          <span className="text-3xl font-bold">My Accounts</span>
        </div>
        <div className="h-[100%] border border-collapse items-center p-4">
          <div className="my-auto">Balance: </div>
        </div>
        <div className="border border-collapse flex flex-row p-4 justify-around">
          <div className="border border-collapse ">Deposit</div>
          <div className="border border-collapse ">Withdraw</div>
          <div className="border border-collapse ">Transfer</div>
        </div>
      </div>
    </>
  );
};

export default AccountInfo;
