/*
 * Copyright 2010 Swiz Framework Contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

package com.heymoose.utils.chain.classes
{

import flash.events.IEventDispatcher;

[Event(name="chainStart", type="com.heymoose.utils.chain.classes.ChainEvent")]
[Event(name="chainStepComplete", type="com.heymoose.utils.chain.classes.ChainEvent")]
[Event(name="chainStepError", type="com.heymoose.utils.chain.classes.ChainEvent")]
[Event(name="chainComplete", type="com.heymoose.utils.chain.classes.ChainEvent")]
[Event(name="chainFail", type="com.heymoose.utils.chain.classes.ChainEvent")]

public interface IChain extends IEventDispatcher
{
	function get position ():int;


	function set position ( value:int ):void;


	function get isComplete ():Boolean;


	function get stopOnError ():Boolean;


	function set stopOnError ( value:Boolean ):void;


	function hasNext ():Boolean;


	function stepComplete ():void;


	function stepError ():void;


	function addStep ( step:IChainStep ):IChain;


	function start ():void;


	function doProceed ():void;
}
}