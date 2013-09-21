using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Tests.Framework
{
    public class Turtle
    {
        private LuaEnvironment _environment;
        public readonly List<string> CallsMade = new List<string>();

        public Turtle(LuaEnvironment environment)
        {
            _environment = environment;
            _environment.CreateTable("turtle");
            _environment.RegisterFunction("turtle.craft", this, () => Craft(0));
            _environment.RegisterFunction("turtle.forward", this, () => Forward());
            _environment.RegisterFunction("turtle.back", this, () => Back());
            _environment.RegisterFunction("turtle.up", this, () => Up());
            _environment.RegisterFunction("turtle.down", this, () => Down());
            _environment.RegisterFunction("turtle.turnLeft", this, () => TurnLeft());
            _environment.RegisterFunction("turtle.turnRight", this, () => TurnRight());
            _environment.RegisterFunction("turtle.select", this, () => Select(0));
            _environment.RegisterFunction("turtle.getItemCount", this, () => GetItemCount(0));
            _environment.RegisterFunction("turtle.getItemSpace", this, () => GetItemSpace(0));
            _environment.RegisterFunction("turtle.attack", this, () => Attack());
            _environment.RegisterFunction("turtle.attackUp", this, () => AttackUp());
            _environment.RegisterFunction("turtle.attackDown", this, () => AttackDown());
            _environment.RegisterFunction("turtle.dig", this, () => Dig());
            _environment.RegisterFunction("turtle.digUp", this, () => DigUp());
            _environment.RegisterFunction("turtle.digDown", this, () => DigDown());
            _environment.RegisterFunction("turtle.place", this, () => Place(""));
            _environment.RegisterFunction("turtle.placeUp", this, () => PlaceUp());
            _environment.RegisterFunction("turtle.placeDown", this, () => PlaceDown());
            _environment.RegisterFunction("turtle.detect", this, () => Detect());
            _environment.RegisterFunction("turtle.detectUp", this, () => DetectUp());
            _environment.RegisterFunction("turtle.detectDown", this, () => DetectDown());
            _environment.RegisterFunction("turtle.compare", this, () => Compare());
            _environment.RegisterFunction("turtle.compareUp", this, () => CompareUp());
            _environment.RegisterFunction("turtle.compareDown", this, () => CompareDown());
            _environment.RegisterFunction("turtle.compareTo", this, () => CompareTo(0));
            _environment.RegisterFunction("turtle.drop", this, () => Drop(0));
            _environment.RegisterFunction("turtle.dropUp", this, () => DropUp(0));
            _environment.RegisterFunction("turtle.dropDown", this, () => DropDown(0));
            _environment.RegisterFunction("turtle.suck", this, () => Suck());
            _environment.RegisterFunction("turtle.suckUp", this, () => SuckUp());
            _environment.RegisterFunction("turtle.suckDown", this, () => SuckDown());
            _environment.RegisterFunction("turtle.refuel", this, () => Refuel(0));
            _environment.RegisterFunction("turtle.getFuelLevel", this, () => GetFuelLevel());
            _environment.RegisterFunction("turtle.transferTo", this, () => TransferTo(0, 0));
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnCraft;
        private bool Craft(int quantity)
        {
            CallsMade.Add("craft(" + quantity + ")");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnCraft != null) OnCraft(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnForward;
        private bool Forward()
        {
            CallsMade.Add("forward()");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnForward != null) OnForward(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnBack;
        private bool Back()
        {
            CallsMade.Add("back()");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnBack != null) OnBack(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnUp;
        private bool Up()
        {
            CallsMade.Add("up()");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnUp != null) OnUp(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnDown;
        private bool Down()
        {
            CallsMade.Add("down()");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnDown != null) OnDown(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnTurnLeft;
        private bool TurnLeft()
        {
            CallsMade.Add("turnLeft()");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnTurnLeft != null) OnTurnLeft(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnTurnRight;
        private bool TurnRight()
        {
            CallsMade.Add("turnRight()");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnTurnRight != null) OnTurnRight(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnAttack;
        private bool Attack()
        {
            CallsMade.Add("attack()");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnAttack != null) OnAttack(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnAttackUp;
        private bool AttackUp()
        {
            CallsMade.Add("attackUp()");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnAttackUp != null) OnAttackUp(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnAttackDown;
        private bool AttackDown()
        {
            CallsMade.Add("attackDown()");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnAttackDown != null) OnAttackDown(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnDig;
        private bool Dig()
        {
            CallsMade.Add("dig()");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnDig != null) OnDig(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnDigUp;
        private bool DigUp()
        {
            CallsMade.Add("digUp()");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnDigUp != null) OnDigUp(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnDigDown;
        private bool DigDown()
        {
            CallsMade.Add("digDown()");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnDigDown != null) OnDigDown(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnPlaceUp;
        private bool PlaceUp()
        {
            CallsMade.Add("placeUp()");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnPlaceUp != null) OnPlaceUp(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnPlaceDown;
        private bool PlaceDown()
        {
            CallsMade.Add("forward()");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnPlaceDown != null) OnPlaceDown(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnDetect;
        private bool Detect()
        {
            CallsMade.Add("detect()");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnDetect != null) OnDetect(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnDetectUp;
        private bool DetectUp()
        {
            CallsMade.Add("detectUp()");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnDetectUp != null) OnDetectUp(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnDetectDown;
        private bool DetectDown()
        {
            CallsMade.Add("detectDown()");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnDetectDown != null) OnDetectDown(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnCompare;
        private bool Compare()
        {
            CallsMade.Add("compare()");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnCompare != null) OnCompare(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnCompareUp;
        private bool CompareUp()
        {
            CallsMade.Add("compareUp()");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnCompareUp != null) OnCompareUp(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnCompareDown;
        private bool CompareDown()
        {
            CallsMade.Add("compareDown()");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnCompareDown != null) OnCompareDown(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnSuck;
        private bool Suck()
        {
            CallsMade.Add("suck()");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnSuck != null) OnSuck(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnSuckUp;
        private bool SuckUp()
        {
            CallsMade.Add("suckUp()");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnSuckUp != null) OnSuckUp(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnSuckDown;
        private bool SuckDown()
        {
            CallsMade.Add("suckDown()");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnSuckDown != null) OnSuckDown(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<int>> OnGetFuelLevel;
        private int GetFuelLevel()
        {
            CallsMade.Add("forward()");
            var result = new LuaResultEventArgs<int> { Result = 0 };
            if (OnGetFuelLevel != null) OnGetFuelLevel(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnSelect;
        private bool Select(int slotNum)
        {
            CallsMade.Add("select(" + slotNum + ")");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnSelect != null) OnSelect(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<int>> OnGetItemCount;
        private int GetItemCount(int slotNum)
        {
            CallsMade.Add("getItemCount(" + slotNum + ")");
            var result = new LuaResultEventArgs<int> { Result = 0 };
            if (OnGetItemCount != null) OnGetItemCount(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<int>> OnGetItemSpace;
        private int GetItemSpace(int slotNum)
        {
            CallsMade.Add("getItemSpace(" + slotNum + ")");
            var result = new LuaResultEventArgs<int> { Result = 0 };
            if (OnGetItemSpace != null) OnGetItemSpace(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnCompareTo;
        private bool CompareTo(int slotNum)
        {
            CallsMade.Add("compareTo(" + slotNum + ")");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnCompareTo != null) OnCompareTo(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnDrop;
        private bool Drop(int quantity)
        {
            CallsMade.Add("drop(" + quantity + ")");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnDrop != null) OnDrop(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnDropUp;
        private bool DropUp(int quantity)
        {
            CallsMade.Add("dropUp(" + quantity + ")");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnDropUp != null) OnDropUp(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnDropDown;
        private bool DropDown(int quantity)
        {
            CallsMade.Add("dropDown(" + quantity + ")");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnDropDown != null) OnDropDown(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnRefuel;
        private bool Refuel(int quantity)
        {
            CallsMade.Add("refuel(" + quantity + ")");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnRefuel != null) OnRefuel(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnPlace;
        private bool Place(string signText = "")
        {
            CallsMade.Add("place(" + (signText ?? "") + ")");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnPlace != null) OnPlace(this, result);
            return result.Result;
        }

        public event EventHandler<LuaResultEventArgs<bool>> OnTransferTo;
        private bool TransferTo(int slotNum, int quantity = 0)
        {
            CallsMade.Add("transferTo(" + slotNum + "," + quantity + ")");
            var result = new LuaResultEventArgs<bool> { Result = true };
            if (OnTransferTo != null) OnTransferTo(this, result);
            return result.Result;
        }
    }
}
