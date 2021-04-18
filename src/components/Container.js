export default function Container({ children }) {
  return (
    <div className="swapwrapper mt-5">
      <div className="swapcard">{children}</div>
    </div>
  );
}
