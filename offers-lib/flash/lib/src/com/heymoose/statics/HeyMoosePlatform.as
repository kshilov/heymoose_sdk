/**
 * Created by IntelliJ IDEA.
 * User: Sokolov Stanislav
 * Date: 11/23/11
 * Time: 11:48 PM
 */
package com.heymoose.statics
{

public class HeyMoosePlatform
{
	public static var vkontakte:String = "VKONTAKTE";
	public static var odnoklassniki:String = "ODNOKLASSNIKI";
	public static var moimir:String = "MOIMIR";
	public static var facebook:String = "FACEBOOK";

	public static function get list ():Array
	{
		var result:Array = new Array ();
		result.push ( {label:'В Контакте', value:vkontakte} );
		result.push ( {label:'Одноклассники', value:odnoklassniki} );
		result.push ( {label:'Мой мир', value:moimir} );
		result.push ( {label:'Facebook', value:facebook} );
		return result;
	}
}
}
